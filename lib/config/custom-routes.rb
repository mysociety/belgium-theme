# Here you can override or add to the pages in the core website

Rails.application.routes.draw do
  # brand new controller example
  # match '/mycontroller' => 'general#mycontroller'
  # Additional help page example
  # match '/help/help_out' => 'help#help_out'

  get '/help/conditions' => 'help#conditions', :as => 'help_conditions'
  get '/help/cada' => 'help#cada', :as => 'help_cada'
end
