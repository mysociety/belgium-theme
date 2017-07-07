# -*- encoding : utf-8 -*-
ALAVETELI_TEST_THEME = 'belgium-theme'
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','..','..','spec','spec_helper'))

describe User do

  let(:user) { FactoryGirl.build(:user) }

  it 'has a postcode attribute' do
    expect{ user.postcode }.to_not raise_error
  end

  it 'has a province attribute' do
    expect{ user.province }.to_not raise_error
  end

end
