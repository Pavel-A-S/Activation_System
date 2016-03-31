class UsersController < ApplicationController
  before_action :human_only
  skip_before_action :human_only, only: [:new, :create]

  def show
    if @human = User.find_by('id = ?', params[:id]) # looks securely
      @tokens = @human.tokens
    end
    return if @human
    flash[:alert] = t(:no_id)
    redirect_to root_path
  end

  def index
    @humans = User.numbering(params[:list], 25, 5) # numbering looks securely
  end

  def new
    if !current_human
      @human = User.new
    else
      flash[:alert] = t(:must_be_logged_out)
      redirect_to root_path
    end
  end

  def create
    if !current_human
      @human = User.new(attributes) # this is handled by model validations
      if @human && @human.save

        # Creating activation token
        begin
          token = SecureRandom.urlsafe_base64
          @human.activation_token = BCrypt::Password.create(token)
        end while User.exists?(activation_token: @human.activation_token)
        @human.avatar = "none"
        @human.activation_request_at = DateTime.now
        @human.activation_status = 'Activated'

        if @human.save
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

  def edit
    @human = User.find_by('id = ?', params[:id]) # looks securely
    if @human && (@human.id == current_human.id || current_human.admin?)
      render 'edit'
    else
      flash[:alert] = t(:restrict_to_change_profile)
      redirect_to root_path
    end
  end

  def update
    @human = User.find_by('id = ?', params[:id]) # looks securely
    if @human && (@human.id == current_human.id || current_human.admin?)
      # Checking for errors
      if attributes
        @human.update_attributes(attributes) # looks securely
        if @human.errors.any?
          render 'edit'
        else
          flash[:message] = t(:successful_update)
          redirect_to user_path(@human.id)
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

  def destroy
    if current_human.admin?
      @human = User.find_by('id = ?', params[:id]) # looks securely
      if @human && @human.id != current_human.id && @human.destroy
        flash[:message] = @human.name + t(:deleted)
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
    params.require(:user).permit(:name,
                                  :email,
                                  :password,
                                  :password_confirmation)
  end

end
