# User controller
class UsersController < ApplicationController
  before_action :user_only
  skip_before_action :user_only, only: [:new, :create]

  # it shows user profile
  def show
    @tokens = @user.tokens if @user = User.find_by('id = ?', params[:id])

    if current_user.admin?
      @requests = Token.where.not('activation_status IS ?', 'Activated')
    end

    return if @user
    flash[:alert] = t(:no_id)
    redirect_to root_path
  end

  # it shows all users
  def index
    @users = User.numbering(params[:list], 25, 5) # numbering looks securely
  end

  # it shows form for creating new user
  def new
    if !current_user
      @user = User.new
    else
      flash[:alert] = t(:must_be_logged_out)
      redirect_to root_path
    end
  end

  # this part creates user profile if profile data is submitted
  def create
    if !current_user # check if not logged in
      @user = User.new(attributes) # this is handled by model validations
      if @user && @user.save

        # creating activation token - not used for this test just emulation
        begin
          token = SecureRandom.urlsafe_base64
          @user.activation_token = BCrypt::Password.create(token)
        end while User.exists?(activation_token: @user.activation_token)
        @user.avatar = 'none'
        @user.activation_request_at = DateTime.now
        @user.activation_status = 'Activated'

        if @user.save
          flash[:message] = t(:new_profile)
          redirect_to login_form_path
        else
          render 'new'
        end
      else
        render 'new'
      end
    else
      flash[:alert] = t(:must_be_logged_out)
      redirect_to root_path
    end
  end

  # shows user edit form
  def edit
    @user = User.find_by('id = ?', params[:id]) # looks securely
    if @user && (@user.id == current_user.id || current_user.admin?)
      render 'edit'
    else
      flash[:alert] = t(:restrict_to_change_profile)
      redirect_to root_path
    end
  end

  # updates user profile if he filed and approved form
  def update
    @user = User.find_by('id = ?', params[:id]) # looks securely
    if @user && (@user.id == current_user.id || current_user.admin?)
      # Checking for errors
      if attributes
        @user.update_attributes(attributes) # looks securely
        if @user.errors.any?
          render 'edit'
        else
          flash[:message] = t(:successful_update)
          redirect_to user_path(@user.id)
        end
      else
        flash[:alert] = t(:no_data)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:restrict_to_change_profile)
      redirect_to root_path
    end
  end

  # destroys profile if user admin
  def destroy
    if current_user.admin?
      @user = User.find_by('id = ?', params[:id]) # looks securely
      if @user && @user.id != current_user.id && @user.destroy
        flash[:message] = @user.name + t(:deleted)
        redirect_to users_path
      else
        flash[:alert] = t(:delete_profile_problem)
        redirect_to root_path
      end
    else
      flash[:alert] = t(:nope)
      redirect_to root_path
    end
  end

  private

  def attributes
    return if params[:user].blank? || !params[:user].is_a?(Hash)
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end
