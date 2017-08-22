# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do

  let(:user) { FactoryGirl.build(:user) }

  it 'has a postcode attribute' do
    expect{ user.postcode }.to_not raise_error
  end

  it 'has a province attribute' do
    expect{ user.province }.to_not raise_error
  end

  it 'requires the province to be set for new users' do
    user.valid?
    expect(user.errors.messages.first).
      to eq([:province, ['Please select the province you live in']])
  end

  it 'allows pre-existing users to not have a province set' do
    user = users(:bob_smith_user)
    expect(user.province.blank?).to be true
    expect(user.valid?).to be true
  end

end
