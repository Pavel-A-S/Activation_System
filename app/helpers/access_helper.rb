# Just an AccessHelper
module AccessHelper
  private

  # checks if user is logged in
  def user_only
    # if user has cookie
    if !session[:user_id] && cookies[:user_card] && cookies[:user_id]
      @user = User.find_by('id = ?', cookies.signed[:user_id]) # ok
      if @user &&
         !@user.user_card.blank? &&
         user_card = cookies.signed[:user_card] # ok

        if BCrypt::Password.new(user_card).is_password?(@user.user_card)
          session[:user_id] = @user.id
          @user.last_login = DateTime.now
          @user.save(validate: false)
        end
      end

    # if user has session
    elsif session[:user_id] && @user = User.find_by('id = ?',
                                                    session[:user_id]) # ok
      @user.last_login = DateTime.now
      @user.save(validate: false)
    end

    # checks if user activated
    return if session[:user_id] &&
              @user &&
              @user.activation_status == 'Activated'

    # shows error messages
    if session[:user_id] &&
       @user &&
       @user.activation_status != 'Activated'

      flash[:alert] = t(:banned)
    else
      flash[:alert] = t(:log_in_request)
    end

    # destroys all activation data
    session.delete(:user_id) if session[:user_id]
    cookies.delete(:user_id) if cookies[:user_id]
    cookies.delete(:user_card) if cookies[:user_card]
    redirect_to login_form_path
  end

  # check if user is inside
  def user_inside?
    if session[:user_id]
      return true
    elsif cookies[:user_card]
      user_only
      return true
    else
      return false
    end
  end

  # determine current user
  def current_user
    User.find_by('id = ?', session[:user_id]) # ok
  end
end
