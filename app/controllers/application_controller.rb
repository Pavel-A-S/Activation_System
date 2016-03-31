# Just an application controller
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include AccessHelper

  # I18n
  before_action :set_locale

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def set_locale
    if params[:language] == 'en'
      cookies.permanent[:language] = 'en'
      locale = 'en'
    elsif params[:language] == 'ru'
      cookies.permanent[:language] = 'ru'
      locale = 'ru'
    elsif cookies[:language] == 'en'
      locale = 'en'
    elsif cookies[:language] == 'ru'
      locale = 'ru'
    elsif params[:locale] == 'en'
      locale = 'en'
    elsif params[:locale] == 'ru'
      locale = 'ru'
    end

    I18n.locale = locale || I18n.default_locale
  end
end
