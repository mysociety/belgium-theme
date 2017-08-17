# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Signing up' do

  it 'allows a user to enter their province' do
    visit signup_path

    within '#signup' do
      fill_in 'Your e-mail', :with => 'test@localhost'
      fill_in 'Your name', :with => 'rspec'
      fill_in 'Password', :with => 'secret'
      fill_in 'Confirm password:', :with => 'secret'
      select 'Bruxelles', :from => 'Your province (optional):'
      click_button 'Sign up'
    end

    visit confirm_url(:email_token => PostRedirect.last.email_token)
    visit signchangeprovince_path(:url_name => 'rspec')

    expect(find_field('New province:').value).to eq 'Bruxelles'
  end

  it 'allows a user to leave the province field blank' do
    visit signup_path

    within '#signup' do
      fill_in 'Your e-mail', :with => 'test@localhost'
      fill_in 'Your name', :with => 'rspec'
      fill_in 'Password', :with => 'secret'
      fill_in 'Confirm password:', :with => 'secret'
      click_button 'Sign up'
    end

    visit confirm_url(:email_token => PostRedirect.last.email_token)
    visit signchangeprovince_path(:url_name => 'rspec')

    expect(find_field('New province:').value).to eq ""
  end

end

describe 'Managing province data' do

  let(:user) { login(FactoryGirl.create(:user, :province => 'Bruxelles')) }

  it 'allows a user to change their province' do
    using_session(user) do
      visit signchangeprovince_path
      select 'Luxembourg', :from => 'New province:'
      click_button "Change province on #{AlaveteliConfiguration.site_name}"

      visit signchangeprovince_path
      expect(find_field('New province:').value).to eq('Luxembourg')
    end
  end

  it 'allows a user to remove their province data' do
    using_session(user) do
      visit signchangeprovince_path
      select 'Please select the province you live in (optional)',
             :from => 'New province:'
      click_button "Change province on #{AlaveteliConfiguration.site_name}"

      visit signchangeprovince_path
      expect(find_field('New province:').value).to eq('')
    end
  end

end
