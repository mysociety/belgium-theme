# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Signing up' do

  it 'allows a user to enter their postcode' do
    visit signup_path

    within '#signup' do
      fill_in 'Your e-mail', :with => 'test@localhost'
      fill_in 'Your name', :with => 'rspec'
      fill_in 'Password', :with => 'secret'
      fill_in 'Confirm password:', :with => 'secret'
      fill_in 'Your postcode (optional)', :with => 'SW1A 1AA'
      click_button 'Sign up'
    end

    visit confirm_url(:email_token => PostRedirect.last.email_token)
    visit signchangepostcode_path(:url_name => 'rspec')

    expect(find_field('New postcode:').value).to eq('SW1A 1AA')
  end

  it 'allows a user to leave the postcode field blank' do
    visit signup_path

    within '#signup' do
      fill_in 'Your e-mail', :with => 'test@localhost'
      fill_in 'Your name', :with => 'rspec'
      fill_in 'Password', :with => 'secret'
      fill_in 'Confirm password:', :with => 'secret'
      click_button 'Sign up'
    end

    visit confirm_url(:email_token => PostRedirect.last.email_token)
    visit signchangepostcode_path(:url_name => 'rspec')

    expect(find_field('New postcode:').value).to be nil
  end

end

describe 'Managing postcode data' do

  let(:user) { login(FactoryGirl.create(:user, :postcode => 'SW1A 1AA')) }

  it 'allows a user to change their postcode' do
    using_session(user) do
      visit signchangepostcode_path
      fill_in 'New postcode:', :with => 'SW1A 0AA'
      click_button "Change postcode on #{AlaveteliConfiguration.site_name}"

      visit signchangepostcode_path
      expect(find_field('New postcode:').value).to eq('SW1A 0AA')
    end
  end

  it 'allows a user to remove their postcode data' do
    using_session(user) do
      visit signchangepostcode_path
      fill_in 'New postcode:', :with => ''
      click_button "Change postcode on #{AlaveteliConfiguration.site_name}"

      visit signchangepostcode_path
      expect(find_field('New postcode:').value).to be nil
    end
  end

end
