require 'rails_helper'

RSpec.describe AccessController, type: :controller do
  before(:each) do
    @locale = 'en'
    @good_man = User.find_by(email: 'goodman@test.com')
    @good_attributes = { name: 'Good Man',
                         email: 'GoodMan@test.com',
                         password: '12345678',
                         password_confirmation: '12345678',
                         get_user_card: '1' }

    @no_cookie_attributes = { name: 'Good Man',
                              email: 'GoodMan@test.com',
                              password: '12345678',
                              password_confirmation: '12345678',
                              get_user_card: '' }

    @bad_attributes = { name: 'lalala',
                        email: 'Good@Man@test.com',
                        password: '87654321',
                        password_confirmation: 'nope',
                        get_user_card: '2' }
  end

  #-------------------------- create_session action ----------------------------

  # with good data must get access
  it 'If right attributes - must get access' do
    post :create_session, access: @good_attributes, locale: @locale
    expect(cookies.signed[:user_card].blank?).not_to be true
    expect(cookies.signed[:user_id].blank?).not_to be true
    expect(session[:user_id].blank?).not_to be true
    expect(response).to redirect_to user_path(assigns(:user).id)
    expect(flash.empty?).not_to be true
  end

  # with good data (except cookie) must get access
  it 'If right attributes (no cookie) - must get access' do
    post :create_session, access: @no_cookie_attributes, locale: @locale
    expect(cookies.signed[:user_card].blank?).to be true
    expect(cookies.signed[:user_id].blank?).to be true
    expect(session[:user_id].blank?).not_to be true
    expect(response).to redirect_to user_path(assigns(:user).id)
    expect(flash.empty?).not_to be true
  end

  # with wrong data mustn't get access
  it 'If wrong attributes - must be handled' do
    post :create_session, access: @bad_attributes, locale: @locale
    expect(cookies.signed[:user_card].blank?).to be true
    expect(cookies.signed[:user_id].blank?).to be true
    expect(session[:user_id].blank?).to be true
    expect(response).to render_template :login_form
    expect(flash.empty?).not_to be true
  end

  # with empty data or wrong type mustn't get access
  it 'If empty or wrong type attributes - must be handled' do
    post :create_session, access: 'lalala', locale: @locale
    expect(cookies.signed[:user_card].blank?).to be true
    expect(cookies.signed[:user_id].blank?).to be true
    expect(session[:user_id].blank?).to be true
    expect(response).to render_template :login_form
    expect(flash.empty?).not_to be true
  end

  #-------------------------- destroy_session action ---------------------------

  # cookies and sessions must be destroyed
  it 'cookies and sessions must be destroyed' do
    # create
    post :create_session, access: @good_attributes, locale: @locale
    expect(cookies.signed[:user_card].blank?).not_to be true
    expect(cookies.signed[:user_id].blank?).not_to be true
    expect(session[:user_id].blank?).not_to be true

    # destroy
    delete :destroy_session, locale: @locale
    expect(cookies.signed[:user_card].blank?).to be true
    expect(cookies.signed[:user_id].blank?).to be true
    expect(session[:user_id].blank?).to be true
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).not_to be true
  end
end
