require 'rails_helper'

RSpec.describe Token, type: :model do
  before(:each) do
    @good_attributes = { name: 'MyDevice',
                         MAC: 'af:bf:cf:dF:ef:7f' }

    @wrong_attributes = { name: nil,
                          MAC: 'af:bf:cf:df:ef:gf' }

    @second_wrong_attributes = { name: 'M' * 26,
                                 MAC: nil }
  end

  it 'Must not be errors if attributes are correct' do
    @user = Token.create(@good_attributes)
    expect(@user.errors.size).to eq(0)
  end

  it 'Name must be present' do
    @user = Token.create(@wrong_attributes)
    expect(@user.errors[:name].size).to eq(1)
  end

  it 'Name length must not be more than 25 symbols' do
    @user = Token.create(@second_wrong_attributes)
    expect(@user.errors[:name].size).to eq(1)
  end

  it 'MAC must be correct' do
    @user = Token.create(@wrong_attributes)
    expect(@user.errors[:MAC].size).to eq(1)
  end

  it 'MAC must be present' do
    @user = Token.create(@second_wrong_attributes)
    expect(@user.errors[:MAC].size).to eq(1)
  end
end
