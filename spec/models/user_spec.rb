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

end
