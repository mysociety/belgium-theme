# -*- encoding : utf-8 -*-
# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do

  # Example of adding a default text to each message
  # OutgoingMessage.class_eval do
  #   # Add intro paragraph to new request template
  #   def default_letter
  #     return nil if self.message_type == 'followup'
  #     "If you uncomment this line, this text will appear as default text in every message"
  #   end
  # end

  User.class_eval do
    strip_attributes only: [:province, :postcode]

    validates_presence_of :province,
                          :on => :create,
                          :message => _('Please select the province you ' \
                                        'live in')

    def self.province_name_options
      if FastGettext.locale == 'nl_BE'
        [
          'Antwerpen',
          'Brussel',
          'Limburg',
          'Oost-Vlaanderen',
          'West-Vlaanderen',
          'Vlaams Brabant',
          'Andere'
        ]
      else
        [
          'Brabant Wallon',
          'Bruxelles',
          'Hainaut',
          'Liège',
          'Luxembourg',
          'Namur',
          'Autre'
        ]
      end
    end
  end
end
