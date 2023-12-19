# Here you can override or add to the pages in the core website

Rails.application.routes.draw do
  # brand new controller example
  # get '/mycontroller' => 'general#mycontroller'
  # Additional help page example
  # get '/help/help_out' => 'help#help_out'

  get '/participer', to: redirect('http://anticor.be/participer')
  get '/neemdeel', to: redirect('http://anticor.be/neemdeel')

  get '/help/conditions' => 'help#conditions', :as => 'help_conditions'
  get '/help/cada' => 'help#cada', :as => 'help_cada'

  scope '/profile' do
    match '/change_postcode' => 'user#signchangepostcode',
          :as => :signchangepostcode,
          :via => [:get, :post]
    match '/change_province' => 'user#signchangeprovince',
          :as => :signchangeprovince,
          :via => [:get, :post]
  end

  match '/request/:url_title/download_saisine' => 'request#download_entire_request_saisine',
        :as => :download_entire_request_saisine,
        :via => :get
end
