require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  def log_in(id)
    session[:user_id] = id
  end

  before(:each) do
    @locale = 'en'
    @good_man = User.find_by(email: 'goodman@test.com')
    @bad_man = User.find_by(email: 'badman@test.com')
    @admin = User.find_by(email: 'admin@test.com')
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
  it "show action: logged out users mustn't get access" do
    get :show, id: @good_man.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must get access
  it 'show action: logged in users must get access' do
    log_in(@good_man.id)
    get :show, id: @good_man.id, locale: @locale
    expect(response).to be_success
  end

  # user id must be right
  it 'show acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :show, id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #-------------------------------- new action ---------------------------------

  # logged out users must have access
  it 'new action: logged out users must have access' do
    get :new, locale: @locale
    expect(response).to be_success
  end

  # logged in users must be redirected
  it "new action: logged in users mustn't have access" do
    log_in(@good_man.id)
    get :new, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #------------------------------- index action --------------------------------

  # logged out users must be redirected to login page
  it "index action: logged out users mustn't get access" do
    get :index, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must get access
  it 'index action: logged in users must get access' do
    log_in(@good_man.id)
    get :index, locale: @locale
    expect(response).to be_success
  end

  #------------------------------- create action -------------------------------

  # logged in users mustn't get access
  it "create action: logged in users mustn't get access" do
    log_in(@good_man.id)
    post :create, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash[:alert]).to_not be_nil
  end

  # users must be redirected to login path if success
  it 'create action: if success - should be redirected to root_path' do
    post :create, user: @good_attributes, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # wrong attributes request must be handled
  it "create action: if any errors user mustn't be redirected" do
    post :create, user: @bad_attributes, locale: @locale
    expect(response).to render_template :new
    expect(assigns(:user).errors.any?).to be true
  end

  # if "no attributes" request - must be handled
  it "create action: if 'no attributes request' - must be handled" do
    post :create, locale: @locale
    expect(response).to render_template :new
    expect(assigns(:user).errors.any?).to be true
  end

  # if "wrong type attributes" request - must be handled
  it "create action: if 'wrong type attributes request' - must be handled" do
    post :create, user: 'lalala', locale: @locale
    expect(response).to render_template :new
    expect(assigns(:user).errors.any?).to be true
  end

  #---------------------------------- edit action ------------------------------

  # logged out users must be redirected to login form
  it "edit action: logged out users mustn't have access" do
    get :edit, id: @good_man.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # user mustn't have ability to change someone else profile
  it "edit action: user mustn't change someone else profile" do
    log_in(@bad_man.id)
    get :edit, id: @good_man.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # logged in user must have access to change his profile
  it 'edit action: logged in user must have access to change his profile' do
    log_in(@good_man.id)
    get :edit, id: @good_man.id, locale: @locale
    expect(response).to be_success
  end

  # admin must have access to change any profile
  it 'edit action: admin must have access to change any profile' do
    log_in(@admin.id)
    get :edit, id: @good_man.id, locale: @locale
    expect(response).to be_success
  end

  # user id must be right
  it 'edit acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    get :edit, id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #--------------------------------- update action -----------------------------

  # logged out users must be redirected to login form
  it "update action: logged out users mustn't have access" do
    patch :update, id: @good_man.id,
                   user: @good_attributes,
                   locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # user mustn't have ability to change someone else profile
  it "update action: user mustn't change someone else profile" do
    log_in(@bad_man.id)
    patch :update, id: @good_man.id,
                   user: @good_attributes,
                   locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must have access to change their profile
  it 'update action: users must have access to change their profile' do
    log_in(@good_man.id)
    patch :update, id: @good_man.id,
                   user: @good_attributes,
                   locale: @locale
    expect(response).to redirect_to user_path(@good_man.id)
  end

  # admin must have access to change any profile
  it 'update action: admin must have access to change any profile' do
    log_in(@admin.id)
    patch :update, id: @good_man.id,
                   user: @good_attributes,
                   locale: @locale
    expect(response).to redirect_to user_path(@good_man.id)
  end

  # user id must be right
  it 'update acton: if wrong id user must be redirected' do
    log_in(@good_man.id)
    patch :update, id: 'wrong_id',
                   user: @good_attributes,
                   locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # wrong attributes request must be handled
  it "update action: if any errors user mustn't be redirected" do
    log_in(@good_man.id)
    patch :update, id: @good_man.id,
                   user: @bad_attributes,
                   locale: @locale
    expect(response).to render_template :edit
    expect(assigns(:user).errors.any?).to be true
  end

  # if "no attributes" request - must be handled
  it "update action: if 'no attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_man.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # if "empty attributes" request - must be handled
  it "update action: if 'empty attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_man.id,
                   user: {},
                   locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # if "wrong type attributes" request - must be handled
  it "update action: if 'wrong type attributes request' - must be handled" do
    log_in(@good_man.id)
    patch :update, id: @good_man.id,
                   user: 'lalala',
                   locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  #-------------------------------- destroy action -----------------------------

  # logged out users must be redirected to login form
  it 'destroy action: logged out users must be redirected to login form' do
    delete :destroy, id: @good_man.id, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users mustn't have ability to delete any profile
  it "destroy action: users mustn't have ability to delete any profile" do
    log_in(@good_man.id)
    delete :destroy, id: @good_man.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # admin must have access to destroy someone else profile
  it 'destroy action: admin must have access to destroy other profile' do
    log_in(@admin.id)
    delete :destroy, id: @good_man.id, locale: @locale
    expect(response).to redirect_to users_path
    expect(flash.empty?).to_not be true
  end

  # admin mustn't have access to destroy his profile
  it "destroy action: admin mustn't have access to destroy his profile" do
    log_in(@admin.id)
    delete :destroy, id: @admin.id, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # user id must be right
  it 'destroy action: user id must be right' do
    log_in(@admin.id)
    delete :destroy, id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end
end
