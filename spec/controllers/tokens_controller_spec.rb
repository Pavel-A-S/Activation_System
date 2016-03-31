require 'rails_helper'

RSpec.describe TokensController, type: :controller do
  fixtures :Tokens

  def log_in(id)
    session[:human_id] = id
  end

  before(:each) do
    @good_man_id = 23
    @admin_id = 24
    @bad_man_id = 25
    @locale = 'en'
    @good_activation_token = '_IEwoSDV_ziECeAy8BzcAA'
    @good_activation_token2 = '_IEwoSDV_ziECeAy8BzcA2'
    @new_activation_token = '7IEwoSDV_ziECeAy8BzcA2'
    @bad_activation_token = 'Wrong'
    @permanent_good_user_token = 'vrZAh3qy3wYB2dlEkwNwY1'
    @response_json_activated = { status: 'Activated',
                                 token: 'vrZAh3qy3wYB2dlEkwNwYQ' }.to_json
    @response_json_nochanges = { status: 'NoChanges' }.to_json
    @response_to_user_json_activated = { status: 'Activated' }.to_json
    @good_attributes = { name: 'MyDevice', :MAC => '00:21:14:a7:01:43' }
    @bad_attributes = {}

  end

  #-------------------------------- show action --------------------------------

  # device must get access
  it "show action: device must get access" do
    get :show, id: @good_activation_token, locale: @locale
    expect(assigns(:token).activation_token).to eq(@good_activation_token)
    expect(response.body).to eq(@response_json_nochanges)
    expect(response).to be_success
  end

  # token must be right
  it "show action: token must be right" do
    get :show, id: @bad_activation_token, locale: @locale
    expect(assigns(:token)).to be nil
    expect(response.body).to eq(@response_json_nochanges)
    expect(response).to be_success
  end

  # if it's first connection token must be sent
  it "show action: token must be sent" do
    get :show, id: @good_activation_token2, locale: @locale
    expect(assigns(:token).activation_token).to eq(@good_activation_token2)
    expect(response.body).to eq(@response_json_activated)
    expect(response).to be_success
  end

  #--------------------------------- update action -----------------------------

  # logged out users must be redirected to login form
  it "update action: logged out users mustn't have access" do
    patch :update, id: @new_activation_token, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in users must have access to add device
  it 'update action: users must have access to add device' do
    log_in(@good_man_id)
    patch :update, id: @new_activation_token, locale: @locale
    expect(response.body).to eq(@response_to_user_json_activated)
    expect(response).to be_success
  end

  # token must be right
  it 'update action: token must be right' do
    log_in(@good_man_id)
    patch :update, id: @bad_activation_token, locale: @locale
    expect(response.body).to eq(@response_json_nochanges)
    expect(response).to be_success
  end

  # token must be assigned to user
  it 'update action: token must be assigned to user' do
    log_in(@good_man_id)
    patch :update, id: @new_activation_token, locale: @locale
    expect(response.body).to eq(@response_to_user_json_activated)
    expect(assigns(:token).user_id).to eq(@good_man_id)
    expect(response).to be_success
  end

  #------------------------------- create action -------------------------------

  # device must get access
  it "create action: device must get access" do
    post :create, device: @good_attributes, locale: @locale
    expect(response).to be_success
  end

  # token must be sent
  it "create action: token must be sent" do
    post :create, device: @good_attributes, locale: @locale
    body_json = JSON(response.body)
    expect(body_json["token"]).not_to be_nil
    expect(body_json["status"]).to eq("Ok")
    expect(response).to be_success
  end

  # if wrong attributes must be error message
  it "create action: must be error message" do
    post :create, device: @bad_attributes, locale: @locale
    body_json = JSON(response.body)
    expect(body_json["status"]).to eq("errors")
    expect(response).to be_success
  end

  #------------------------------- index action --------------------------------

  # logged in users must get access
  it 'index action: logged in users must get access' do
    log_in(@good_man_id)
    get :index, locale: @locale
    expect(response).to be_success
  end

  # logged out users must get access
  it 'index action: logged out users must get access' do
    get :index, locale: @locale
    expect(response).to be_success
  end
  #-------------------------------- destroy action -----------------------------

  # logged out users must be redirected to login form
  it 'destroy action: logged out users must be redirected to login form' do
    delete :destroy, id: @permanent_good_user_token, locale: @locale
    expect(response).to redirect_to login_form_path
    expect(flash.empty?).to_not be true
  end

  # logged in user mustn't have ability to delete other user devices
  it "destroy action: user mustn't have ability to delete other user devices" do
    log_in(@bad_man_id)
    delete :destroy, id: @permanent_good_user_token, locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end

  # logged in user must have ability to delete his devices
  it "destroy action: user must have ability to delete his devices" do
    log_in(@good_man_id)
    delete :destroy, id: @permanent_good_user_token, locale: @locale
    expect(response).to redirect_to user_path(@good_man_id)
    expect(flash.empty?).to_not be true
  end

  # admin must have access to destroy someone else devices
  it 'destroy action: admin must have access to destroy other devices' do
    log_in(@admin_id)
    delete :destroy, id: @permanent_good_user_token, locale: @locale
    expect(response).to redirect_to user_path(@admin_id)
    expect(flash.empty?).to_not be true
  end

  # device id must be right
  it 'destroy action: device id must be right' do
    log_in(@admin_id)
    delete :destroy, id: 'wrong_id', locale: @locale
    expect(response).to redirect_to root_path
    expect(flash.empty?).to_not be true
  end
end
