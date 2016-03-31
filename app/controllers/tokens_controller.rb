class TokensController < ApplicationController
  before_action :human_only, only: [:update, :destroy]

  def index
    @message = Token.new
    @message2 = Token.new
  end

  def show
    if @token = Token.find_by('activation_token = ?', params[:id].to_s)
      if @token.activation_status == "Activated" && @token.sended == false
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

  def update
    @token = Token.find_by('activation_token = ?', params[:id].to_s)
    if @token && @token.activation_status != "Activated"
      @token.activation_status = "Activated"
      @token.user_id = current_human.id
      @token.body = SecureRandom.urlsafe_base64
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

  def create
    if !attributes.blank?
      @token = Token.create(attributes)
      @token.activation_request_at = DateTime.now

      begin
        @token.activation_token = SecureRandom.urlsafe_base64
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

  def destroy
    @token = Token.find_by('body = ?', params[:id])
    if @token && (@token.user_id == current_human.id || current_human.admin?) &&
                  @token.destroy
      flash[:message] = t(:device_deleted)
      redirect_to user_path(current_human.id)
    else
      flash[:alert] = t(:nope)
      redirect_to root_path
    end
  end

  private

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
