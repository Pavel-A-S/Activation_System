require 'test_helper'

class AccessControllerTest < ActionController::TestCase
  def setup
    @locale = 'en'
    @good_man = users(:good_man)
    @good_attributes = { name: 'Good Man',
                         email: 'GoodMan@test.com',
                         password: '12345678',
                         password_confirmation: '12345678',
                         get_human_card: '1' }

    @no_cookie_attributes = { name: 'Good Man',
                              email: 'GoodMan@test.com',
                              password: '12345678',
                              password_confirmation: '12345678',
                              get_human_card: '' }

    @bad_attributes = { name: 'lalala',
                        email: 'Good@Man@test.com',
                        password: '87654321',
                        password_confirmation: 'nope',
                        get_human_card: '2' }
  end

  #-------------------------- create_session action ----------------------------

  # with good data must get access
  test 'If right attributes - must get access' do
    post :create_session, access: @good_attributes, locale: @locale
    assert_not cookies.signed[:human_card].blank?
    assert_not cookies.signed[:human_id].blank?
    assert_not session[:human_id].blank?
    assert_redirected_to user_path(assigns(:human).id)
    assert_not flash.empty?
  end

  # with good data (except cookie) must get access
  test 'If right attributes (no cookie) - must get access' do
    post :create_session, access: @no_cookie_attributes, locale: @locale
    assert cookies.signed[:human_card].blank?
    assert cookies.signed[:human_id].blank?
    assert_not session[:human_id].blank?
    assert_redirected_to user_path(assigns(:human).id)
    assert_not flash.empty?
  end

  # with wrong data mustn't get access
  test 'If wrong attributes - must be handled' do
    post :create_session, access: @bad_attributes, locale: @locale
    assert cookies.signed[:human_card].blank?
    assert cookies.signed[:human_id].blank?
    assert session[:human_id].blank?
    assert_template :login_form
    assert_not flash.empty?
  end

  # with empty data or wrong type mustn't get access
  test 'If empty or wrong type attributes - must be handled' do
    post :create_session, access: 'lalala', locale: @locale
    assert cookies.signed[:human_card].blank?
    assert cookies.signed[:human_id].blank?
    assert session[:human_id].blank?
    assert_template :login_form
    assert_not flash.empty?
  end

  #-------------------------- destroy_session action ---------------------------

  # cookies and sessions must be destroyed
  test 'cookies and sessions must be destroyed' do
    # create
    post :create_session, access: @good_attributes, locale: @locale
    assert_not cookies.signed[:human_card].blank?
    assert_not cookies.signed[:human_id].blank?
    assert_not session[:human_id].blank?

    # destroy
    delete :destroy_session, locale: @locale
    assert cookies.signed[:human_card].blank?
    assert cookies.signed[:human_id].blank?
    assert session[:human_id].blank?
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end
end
