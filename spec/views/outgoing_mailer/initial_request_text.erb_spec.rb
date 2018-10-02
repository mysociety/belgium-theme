# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "outgoing_mailer/initial_request" do

  before do
    # TODO: this is hacky, work out how to set this in the spec_helper
    controller.set_view_paths_for_belgium_theme
  end

  let(:user) { FactoryBot.create(:user, province: 'Autre') }
  let(:body) { FactoryBot.create(:public_body, name: 'Test') }

  let(:request) do
    FactoryBot.create(:info_request, public_body: body, user: user)
  end

  let(:outgoing_message) do
    FactoryBot.create(:initial_request, info_request: request)
  end

  context 'there is only one translation for the public body' do

    it 'only finds one translation' do
      expect(I18n.available_locales.count).to be > 1
      expect(request.public_body.available_locales.count).to eq(1)
    end

    it 'does not render the footer separator' do
      assign(:info_request, request)
      assign(:outgoing_message, outgoing_message)
      render
      expect(response).not_to match("\n--------------\n")
    end

    it 'only includes one copy of the request data' do
      assign(:info_request, request)
      assign(:outgoing_message, outgoing_message)
      render
      expect(response).to have_text(request.public_body.request_email, count: 1)
    end

  end

  context 'there are 2 translations for the public body' do

    let(:body) do
      pb = FactoryBot.create(:public_body, name: 'Test')
      email = pb.request_email
      I18n.with_locale('fr') do
        pb.update_attributes(name: 'Test', request_email: email)
      end
      pb
    end

    it 'finds 2 translations' do
      expect(request.public_body.available_locales.count).to eq(2)
    end

    it 'renders the footer separator' do
      assign(:info_request, request)
      assign(:outgoing_message, outgoing_message)
      render
      expect(response).to match("\n--------------\n")
    end

    it 'includes 2 copies of the request data' do
      assign(:info_request, request)
      assign(:outgoing_message, outgoing_message)
      render
      expect(response).to have_text(request.public_body.request_email, count: 2)
    end

  end

end
