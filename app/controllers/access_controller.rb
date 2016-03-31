# Just an access controller
class AccessController < ApplicationController
  #-------------------- login (create session, cookies) part -------------------

  def login_form
  end

  def create_session
    @human = User.find_by('email = ?',
                           session_attributes[:email].to_s.downcase) # ok
    # grant access
    if @human &&
       @human.authenticate(session_attributes[:password]) &&
       @human.activation_status == 'Activated' # ok

      allow_human_to_pass(@human.id)

      # ok
      give_human_card_to(@human) if session_attributes[:get_human_card] == '1'

      flash[:message] = t(:welcome)
      redirect_to(@human)

    # if not activated
    elsif @human &&
          @human.authenticate(session_attributes[:password]) &&
          @human.activation_status.blank?

      flash[:alert] = t(:activation_problem)
      redirect_to activation_form_path

    # if banned
    elsif @human &&
          @human.authenticate(session_attributes[:password]) &&
          @human.activation_status == 'Nope'

      flash.now[:alert] = t(:banned)
      render 'login_form'

    # if wrong credentials
    else
      flash.now[:alert] = t(:access_problem)
      render 'login_form'
    end
  end

  def destroy_session
    session.delete(:human_id)
    cookies.delete(:human_id)
    cookies.delete(:human_card)
    flash[:message] = t(:successful_logout)
    redirect_to login_form_path
  end

  #-------------------------- activation profile part --------------------------

  def activation_form
  end

  def create_activation
    @human = User.find_by('email =?',
                           activation_attributes[:email].to_s.downcase)
    if @human &&
       @human.activation_status != 'Activated' &&
       (@human.activation_request_at.blank? ||
        @human.activation_request_at < 5.minutes.ago)

      # Generate token
      begin
        token = SecureRandom.urlsafe_base64
        @human.activation_token = BCrypt::Password.create(token)
      end while User.exists?(activation_token: @human.activation_token)
      @human.activation_request_at = DateTime.now

      # Send token and save encrypted part
      if @human.save(validate: false)
        #HumanMailer.account_activation(@human, token).deliver_now
        flash.now[:message] = t(:send_activation_link)
        render 'activation_form'
      end

    # if already activated
    elsif @human && @human.activation_status == 'Activated'
      flash[:alert] = t(:account_already_activated)
      redirect_to login_form_path

    # if short delay
    elsif @human && @human.activation_request_at > 5.minutes.ago
      flash.now[:alert] = t(:activation_delay)
      render 'activation_form'

    # if email doesn't exist
    else
      flash.now[:alert] = t(:no_account)
      render 'activation_form'
    end
  end

  def account_activation
    @human = User.find_by('email =?', params[:email])

    # activation
    if @human &&
       @human.activation_status.blank? &&
       !@human.activation_token.blank? &&
       BCrypt::Password.new(@human.activation_token)
       .is_password?(params[:token])

      @human.activation_status = 'Activated'
      @human.activated_at = DateTime.now
      @human.save(validate: false)
      flash[:message] = t(:successful_activation)
      redirect_to login_form_path

    # if already activated
    elsif @human && @human.activation_status == 'Activated'
      flash[:alert] = t(:account_already_activated)
      redirect_to login_form_path

    # if banned
    else
      flash[:alert] = t(:nope_activation)
      redirect_to root_path
    end
  end

  #---------------------------- reset password part ----------------------------

  def reset_password_form
  end

  def create_reset_link
    @human = User.find_by('email =?', reset_attributes[:email].to_s.downcase)
    if @human && (@human.password_reset_requested_at.blank? ||
                  @human.password_reset_requested_at < 5.minutes.ago)

      # Generate reset password token
      begin
        token = SecureRandom.urlsafe_base64
        @human.password_reset_token = BCrypt::Password.create(token)
      end while User.exists?(password_reset_token: @human.password_reset_token)
      @human.password_reset_requested_at = DateTime.now

      # Send reset token and save encrypted part
      if @human.save(validate: false)
        #HumanMailer.password_reset(@human, token).deliver_now
        flash.now[:message] = t(:send_reset_password_link)
        render 'reset_password_form'
      end

    # if short delay
    elsif @human && @human.password_reset_requested_at > 5.minutes.ago
      flash.now[:alert] = t(:reset_password_delay)
      render 'reset_password_form'

    # if email doesn't exist
    else
      flash.now[:alert] = t(:no_account)
      render 'reset_password_form'
    end
  end

  def reset_password
    @human = User.find_by('email =?', params[:email])

    # creating new password
    if @human &&
       !@human.password_reset_token.blank? &&
       !@human.password_reset_requested_at.blank? &&
       @human.password_reset_requested_at > 30.minutes.ago &&
       BCrypt::Password.new(@human.password_reset_token)
       .is_password?(params[:token])

      password = SecureRandom.urlsafe_base64
      @human.password = password

      # Send password and save encrypted part
      if @human.save(validate: false)
        #HumanMailer.send_password(@human, password).deliver_now
        flash[:message] = t(:send_new_password)
        redirect_to login_form_path
      end
    # if reset password link expired
    elsif @human &&
          !@human.password_reset_token.blank? &&
          !@human.password_reset_requested_at.blank? &&
          @human.password_reset_requested_at < 30.minutes.ago

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
                                            :get_human_card)
    else
      return {}
    end
  end

  def allow_human_to_pass(human_id)
    session[:human_id] = human_id
  end

  def give_human_card_to(human)
    cookies.permanent.signed[:human_id] = human.id
    if human.human_card.blank?
      begin
        human.human_card = SecureRandom.urlsafe_base64
      end while User.exists?(human_card: human.human_card)
      token = BCrypt::Password.create(human.human_card)
      human.save(validate: false) # subtle moment
    else
      token = BCrypt::Password.create(human.human_card)
    end
    cookies.permanent.signed[:human_card] = token
  end
end
