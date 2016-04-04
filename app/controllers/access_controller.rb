# Just an access controller
class AccessController < ApplicationController
  #-------------------- login (create session, cookies) part -------------------

  # shows login form
  def login_form
  end

  def create_session
    @user = User.find_by('email = ?', session_attributes[:email].to_s.downcase)
    # checks if all data are correct
    if @user &&
       @user.authenticate(session_attributes[:password]) &&
       @user.activation_status == 'Activated' # ok

      # creates session for user
      allow_user_to_pass(@user.id)
      # sets cookie
      give_user_card_to(@user) if session_attributes[:get_user_card] == '1'
      flash[:message] = t(:welcome)
      redirect_to(@user)

    # if not activated - not used in this test
    elsif @user &&
          @user.authenticate(session_attributes[:password]) &&
          @user.activation_status.blank?

      flash[:alert] = t(:activation_problem)
      redirect_to activation_form_path

    # if banned - not used in this test
    elsif @user &&
          @user.authenticate(session_attributes[:password]) &&
          @user.activation_status == 'Nope'

      flash.now[:alert] = t(:banned)
      render 'login_form'

    # if wrong credentials
    else
      flash.now[:alert] = t(:access_problem)
      render 'login_form'
    end
  end

  # for logout (destroys cookies and session)
  def destroy_session
    session.delete(:user_id)
    cookies.delete(:user_id)
    cookies.delete(:user_card)
    flash[:message] = t(:successful_logout)
    redirect_to login_form_path
  end

  #-------------------------- activation profile part --------------------------

  # not used in this test
  def activation_form
  end

  # not used in this test
  def create_activation
    @user = User.find_by('email =?', activation_attributes[:email].to_s
                                                                   .downcase)
    if @user &&
       @user.activation_status != 'Activated' &&
       (@user.activation_request_at.blank? ||
        @user.activation_request_at < 5.minutes.ago)

      # Generate token
      begin
        token = SecureRandom.urlsafe_base64
        @user.activation_token = BCrypt::Password.create(token)
      end while User.exists?(activation_token: @user.activation_token)
      @user.activation_request_at = DateTime.now

      # Send token and save encrypted part
      if @user.save(validate: false)
        flash.now[:message] = t(:send_activation_link)
        render 'activation_form'
      end

    # if already activated
    elsif @user && @user.activation_status == 'Activated'
      flash[:alert] = t(:account_already_activated)
      redirect_to login_form_path

    # if short delay
    elsif @user && @user.activation_request_at > 5.minutes.ago
      flash.now[:alert] = t(:activation_delay)
      render 'activation_form'

    # if email doesn't exist
    else
      flash.now[:alert] = t(:no_account)
      render 'activation_form'
    end
  end

  # not used in this test
  def account_activation
    @user = User.find_by('email =?', params[:email])

    # activation
    if @user &&
       @user.activation_status.blank? &&
       !@user.activation_token.blank? &&
       BCrypt::Password.new(@user.activation_token)
       .is_password?(params[:token])

      @user.activation_status = 'Activated'
      @user.activated_at = DateTime.now
      @user.save(validate: false)
      flash[:message] = t(:successful_activation)
      redirect_to login_form_path

    # if already activated
    elsif @user && @user.activation_status == 'Activated'
      flash[:alert] = t(:account_already_activated)
      redirect_to login_form_path

    # if banned
    else
      flash[:alert] = t(:nope_activation)
      redirect_to root_path
    end
  end

  #---------------------------- reset password part ----------------------------

  # shows reset password form - not used in this test
  def reset_password_form
  end

  # not used in this test
  def create_reset_link
    @user = User.find_by('email =?', reset_attributes[:email].to_s.downcase)
    if @user && (@user.password_reset_requested_at.blank? ||
                  @user.password_reset_requested_at < 5.minutes.ago)

      # Generate reset password token
      begin
        token = SecureRandom.urlsafe_base64
        @user.password_reset_token = BCrypt::Password.create(token)
      end while User.exists?(password_reset_token: @user.password_reset_token)
      @user.password_reset_requested_at = DateTime.now

      # Send reset token and save encrypted part
      if @user.save(validate: false)
        flash.now[:message] = t(:send_reset_password_link)
        render 'reset_password_form'
      end

    # if short delay
    elsif @user && @user.password_reset_requested_at > 5.minutes.ago
      flash.now[:alert] = t(:reset_password_delay)
      render 'reset_password_form'

    # if email doesn't exist
    else
      flash.now[:alert] = t(:no_account)
      render 'reset_password_form'
    end
  end

  # not used in this test
  def reset_password
    @user = User.find_by('email =?', params[:email])

    # creating new password
    if @user &&
       !@user.password_reset_token.blank? &&
       !@user.password_reset_requested_at.blank? &&
       @user.password_reset_requested_at > 30.minutes.ago &&
       BCrypt::Password.new(@user.password_reset_token)
       .is_password?(params[:token])

      password = SecureRandom.urlsafe_base64
      @user.password = password

      # Send password and save encrypted part
      if @user.save(validate: false)
        flash[:message] = t(:send_new_password)
        redirect_to login_form_path
      end
    # if reset password link expired
    elsif @user &&
          !@user.password_reset_token.blank? &&
          !@user.password_reset_requested_at.blank? &&
          @user.password_reset_requested_at < 30.minutes.ago

      flash[:alert] = t(:reset_password_link_expired)
      redirect_to root_path
    # if something go wrong
    else
      flash[:alert] = t(:password_something_wrong)
      redirect_to root_path
    end
  end

  #----------------------------- auxiliary functions ---------------------------

  private

  def activation_attributes
    if !params[:access].blank? && params[:access].is_a?(Hash) # ok
      return params.require(:access).permit(:email)
    else
      return {}
    end
  end

  def reset_attributes
    if !params[:access].blank? && params[:access].is_a?(Hash) # ok
      return params.require(:access).permit(:email)
    else
      return {}
    end
  end

  def session_attributes
    if !params[:access].blank? && params[:access].is_a?(Hash) # ok
      return params.require(:access).permit(:name,
                                            :email,
                                            :password,
                                            :password_confirmation,
                                            :get_user_card)
    else
      return {}
    end
  end

  def allow_user_to_pass(user_id)
    session[:user_id] = user_id
  end

  def give_user_card_to(user)
    cookies.permanent.signed[:user_id] = user.id
    if user.user_card.blank?
      begin
        user.user_card = SecureRandom.urlsafe_base64
      end while User.exists?(user_card: user.user_card)
      token = BCrypt::Password.create(user.user_card)
      user.save(validate: false) # subtle moment
    else
      token = BCrypt::Password.create(user.user_card)
    end
    cookies.permanent.signed[:user_card] = token
  end
end
