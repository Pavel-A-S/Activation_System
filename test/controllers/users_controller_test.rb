require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @locale = 'en'
    @good_man = users(:good_man)
    @bad_man = users(:bad_man)
    @admin = users(:admin)
    @good_attributes = { name: 'new man',
                         email: 'email@test.com',
                         password: '12345678',
                         password_confirmation: '12345678' }
    @bad_attributes = { name: '',
                        email: 'email@lalala@test.com',
                        password: 'yep',
                        password_confirmation: 'nope' }
  end

  #-------------------------------- show action --------------------------------

  # logged out users must be redirected to login page
  test "show action: logged out users mustn't get access" do
    get :show, id: @good_man.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must get access
  test 'show action: logged in users must get access' do
    log_in(@good_man.id)
    get :show, id: @good_man.id, locale: @locale
    assert_response :success
  end

  # user id must be right
  test 'show acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :show, id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #-------------------------------- new action ---------------------------------

  # logged out users must have access
  test 'new action: logged out users must have access' do
    get :new, locale: @locale
    assert_response :success
  end

  # logged in users must be redirected
  test "new action: logged in users mustn't have access" do
    log_in(@good_man.id)
    get :new, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #------------------------------- index action --------------------------------

  # logged out users must be redirected to login page
  test "index action: logged out users mustn't get access" do
    get :index, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users must get access
  test 'index action: logged in users must get access' do
    log_in(@good_man.id)
    get :index, locale: @locale
    assert_response :success
  end

  #------------------------------- create action -------------------------------

  # logged in users mustn't get access
  test "create action: logged in users mustn't get access" do
    log_in(@good_man.id)
    post :create, locale: @locale
    assert_redirected_to root_path
    assert_not flash[:alert].empty?
  end

  # users must be redirected to login path if success
  test 'create action: if success - should be redirected to root_path' do
    post :create, user: @good_attributes, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # wrong attributes request must be handled
  test "create action: if any errors user mustn't be redirected" do
    post :create, user: @bad_attributes, locale: @locale
    assert_template :new
    assert assigns(:user).errors.any?
  end

  # if "no attributes" request - must be handled
  test "create action: if 'no attributes request' - must be handled" do
    post :create, locale: @locale
    assert_template :new
    assert assigns(:user).errors.any?
  end

  # if "wrong type attributes" request - must be handled
  test "create action: if 'wrong type attributes request' - must be handled" do
    post :create, user: 'lalala', locale: @locale
    assert_template :new
    assert assigns(:user).errors.any?
  end

  #---------------------------------- edit action ------------------------------

  # logged out users must be redirected to login form
  test "edit action: logged out users mustn't have access" do
    get :edit, id: @good_man.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # user mustn't have ability to change someone else profile
  test "edit action: user mustn't change someone else profile" do
    log_in(@bad_man.id)
    get :edit, id: @good_man.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # logged in user must have access to change his profile
  test 'edit action: logged in user must have access to change his profile' do
    log_in(@good_man.id)
    get :edit, id: @good_man.id, locale: @locale
    assert_response :success
  end

  # admin must have access to change any profile
  test 'edit action: admin must have access to change any profile' do
    log_in(@admin.id)
    get :edit, id: @good_man.id, locale: @locale
    assert_response :success
  end

  # user id must be right
  test 'edit acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :edit, id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #--------------------------------- update action -----------------------------

  # logged out users must be redirected to login form
  test "update action: logged out users mustn't have access" do
    patch :update, id: @good_man.id,
                   user: @good_attributes,
                   locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # user mustn't have ability to change someone else profile
  test "update action: user mustn't change someone else profile" do
    log_in(@bad_man.id)
    patch :update, id: @good_man.id,
                   user: @good_attributes,
                   locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # logged in users must have access to change their profile
  test 'update action: users must have access to change their profile' do
    log_in(@good_man.id)
    patch :update, id: @good_man.id,
                   user: @good_attributes,
                   locale: @locale
    assert_redirected_to user_path(@good_man.id)
  end

  # admin must have access to change any profile
  test 'update action: admin must have access to change any profile' do
    log_in(@admin.id)
    patch :update, id: @good_man.id,
                   user: @good_attributes,
                   locale: @locale
    assert_redirected_to user_path(@good_man.id)
  end

  # user id must be right
  test 'update acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    patch :update, id: 'wrong_id',
                   user: @good_attributes,
                   locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # wrong attributes request must be handled
  test "update action: if any errors user mustn't be redirected" do
    log_in(@good_man.id)
    patch :update, id: @good_man.id,
                   user: @bad_attributes,
                   locale: @locale
    assert_template :edit
    assert assigns(:user).errors.any?
  end

  # if "no attributes" request - must be handled
  test "update action: if 'no attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_man.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # if "empty attributes" request - must be handled
  test "update action: if 'empty attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_man.id,
                   user: {},
                   locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # if "wrong type attributes" request - must be handled
  test "update action: if 'wrong type attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_man.id,
                   user: 'lalala',
                   locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  #-------------------------------- destroy action -----------------------------

  # logged out users must be redirected to login form
  test 'destroy action: logged out users must be redirected to login form' do
    delete :destroy, id: @good_man.id, locale: @locale
    assert_redirected_to login_form_path
    assert_not flash.empty?
  end

  # logged in users mustn't have ability to delete any profile
  test "destroy action: users mustn't have ability to delete any profile" do
    log_in(@good_man.id)
    delete :destroy, id: @good_man.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # admin must have access to destroy someone else profile
  test 'destroy action: admin must have access to destroy other profile' do
    log_in(@admin.id)
    delete :destroy, id: @good_man.id, locale: @locale
    assert_redirected_to users_path
    assert_not flash.empty?
  end

  # admin mustn't have access to destroy his profile
  test "destroy action: admin mustn't have access to destroy his profile" do
    log_in(@admin.id)
    delete :destroy, id: @admin.id, locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end

  # user id must be right
  test 'destroy action: user id must be right' do
    log_in(@admin.id)
    delete :destroy, id: 'wrong_id', locale: @locale
    assert_redirected_to root_path
    assert_not flash.empty?
  end
end
