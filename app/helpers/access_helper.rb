# Just an AccessHelper
module AccessHelper
  private

  # check if human has permission
  def human_only
    if !session[:human_id] && cookies[:human_card] && cookies[:human_id]
      @human = User.find_by('id = ?', cookies.signed[:human_id]) # ok
      if @human &&
         !@human.human_card.blank? &&
         human_card = cookies.signed[:human_card] # ok

        if BCrypt::Password.new(human_card).is_password?(@human.human_card)
          session[:human_id] = @human.id
          @human.last_login = DateTime.now
          @human.save(validate: false)
        end
      end

    elsif session[:human_id]
      @human = User.find_by('id = ?', session[:human_id]) # ok
      @human.last_login = DateTime.now
      @human.save(validate: false)
    end

    return if session[:human_id] &&
              @human &&
              @human.activation_status == 'Activated'

    if session[:human_id] &&
       @human &&
       @human.activation_status != 'Activated'

      flash[:alert] = t(:banned)
    else
      flash[:alert] = t(:log_in_request)
    end

    session.delete(:human_id) if session[:human_id]
    cookies.delete(:human_id) if cookies[:human_card]
    cookies.delete(:human_card) if cookies[:human_id]
    redirect_to login_form_path
  end

  # check if human is inside
  def human_inside?
    if session[:human_id]
      return true
    else
      return false
    end
  end

  # determine current human
  def current_human
    User.find_by('id = ?', session[:human_id]) # ok
  end
end
