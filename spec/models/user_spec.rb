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

  describe '.province_name_options' do

    it 'returns the French names by default' do
      expect(User.province_name_options).to include('Bruxelles')
    end

    it 'returns a specific locale if found' do
      # TODO - tidy this up when we get the locale handling library (0.30?)
      begin
        available_locales = I18n.available_locales
        I18n.available_locales << :'nl-BE'
        FastGettext.default_available_locales =
          I18n.available_locales.map { |x| x.to_s.gsub('-', '_') }
        I18n.with_locale('nl_BE') do
          expect(User.province_name_options).to include('Brussel')
        end
      ensure
        I18n.available_locales = available_locales
        FastGettext.available_locales =
          I18n.available_locales.map { |x| x.to_s.gsub('-', '_') }
      end
    end

  end

  context 'when validating' do

    it 'allows province to be blank' do
      user.province = ''
      expect(user.valid?).to be true
    end

    it 'allows province to be a value from User.province_name_options' do
      user.province = 'Bruxelles'
      expect(user.valid?).to be true
    end

    it 'sees province as valid when not from currently selected locale' do
      user.province = 'Antwerpen'
      expect(user.valid?).to be true
    end

    it 'adds an error message if province is set to an unexpected value' do
      user.province = 'London'
      expect(user.valid?).to be false
      expect(user.errors[:province]).
        to include('Please enter a valid province')
    end

  end

end
