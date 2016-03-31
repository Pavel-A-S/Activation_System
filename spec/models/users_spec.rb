require 'rails_helper'

RSpec.describe User, type: :model do
  before(:each) do
    @good_attributes = { name: 'Test',
                         email: 'test@test.test',
                         password: '12345678',
                         password_confirmation: '12345678' }

    @wrong_attributes = { name: nil,
                          email: 'Wrong email',
                          password: '1234567',
                          password_confirmation: nil }

    @second_wrong_attributes = { name: 'T' * 49,
                                 email: '12345' * 19 + '@te.st',
                                 password: '12345678',
                                 password_confirmation: '1234567' }
  end

  it 'Must not be errors if attributes are correct' do
    @human = User.create(@good_attributes)
    expect(@human.errors.size).to eq(0)
  end

  it 'Name must be present' do
    @human = User.create(@wrong_attributes)
    expect(@human.errors[:name].size).to eq(1)
  end

  it 'Name length must not be more than 48 symbols' do
    @human = User.create(@second_wrong_attributes)
    expect(@human.errors[:name].size).to eq(1)
  end

  it 'Email must be present and be correct' do
    @human = User.create(@wrong_attributes)
    expect(@human.errors[:email].size).to eq(1)
  end

  it 'Email length must not be more than 100 symbols' do
    @human = User.create(@second_wrong_attributes)
    expect(@human.errors[:email].size).to eq(1)
  end

  it 'Password length must be at least 8 symbols' do
    @human = User.create(@wrong_attributes)
    expect(@human.errors[:password].size).to eq(1)
  end

  it 'Password and password confirmation must match' do
    @human = User.create(@second_wrong_attributes)
    expect(@human.errors[:password_confirmation].size).to eq(1)
  end
end
