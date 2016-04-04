# Tokens controller
class TokensController < ApplicationController
  before_action :user_only, only: [:update, :destroy]

  # main part of programm (User and Device interface)
  def index
    @message = Token.new
  end

  # sends status (and permanent token if activated) to device (Device part)
  def show
    if @token = Token.find_by('activation_token = ?', params[:id].to_s)
      if @token.activation_status == 'Activated' && @token.sended == false
        @token.sended = true
        @token.save
        render json: { status: 'Activated', token: @token.body }
      else
        render json: { status: 'NoChanges' }
      end
    else
      render json: { status: 'NoChanges' }
    end
  end

  # checks user token and binds device to user profile (User part)
  def update
    @token = Token.find_by('activation_token = ?', params[:id].to_s)
    if @token && @token.activation_status != 'Activated'
      @token.activation_status = 'Activated'
      @token.user_id = current_user.id
      @token.body = SecureRandom.urlsafe_base64 # generates permanent token
      @token.activated_at = DateTime.now
      if @token.save
        render json: { status: 'Activated' }
      else
        render json: { status: 'NoChanges' }
      end
    else
      render json: { status: 'NoChanges' }
    end
  end

  # gets device request and sends temporary key as answer as json (Device part)
  def create
    if !attributes.blank?
      @token = Token.create(attributes)
      @token.activation_request_at = DateTime.now

      begin
        @token.activation_token = SecureRandom.urlsafe_base64 # activation token
      end while Token.exists?(activation_token: @token.activation_token)

      if @token.save
        render json: { status: 'Ok', token: @token.activation_token }
      else
        render json: { status: 'errors', errors: get_errors(@token) }
      end
    else
      render json: { status: 'errors' }
    end
  end

  # destroys device bind if user requested it (User part)
  def destroy
    @token = Token.find_by('id = ?', params[:id])
    if @token && (@token.user_id == current_user.id || current_user.admin?) &&
       @token.destroy
      flash[:message] = t(:device_deleted)
      redirect_to user_path(current_user.id)
    else
      flash[:alert] = t(:nope)
      redirect_to root_path
    end
  end

  private

  # prepare errors for json
  def get_errors(object)
    errors = []
    object.errors.full_messages.each do |error|
      errors << error
    end
    errors
  end

  def attributes
    if !params[:device].blank? && params[:device].is_a?(Hash)
      return params.require(:device).permit(:MAC, :name) # ok
    else
      return {}
    end
  end
end
