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

    validate :province_is_valid

    def self.province_name_options
      all_province_names[FastGettext.locale.to_sym] ||
      all_province_names[:default]
    end

    def valid_province?
      province.blank? ||
      User.all_province_names.values.flatten.uniq.include?(province)
    end

    private

    def self.all_province_names
      {
        :default =>
          [
            'Brabant Wallon',
            'Bruxelles',
            'Hainaut',
            'Liège',
            'Luxembourg',
            'Namur',
            'Autre'
        ],
        :nl_BE =>
          [
            'Antwerpen',
            'Brussel',
            'Limburg',
            'Oost-Vlaanderen',
            'West-Vlaanderen',
            'Vlaams Brabant',
            'Andere'
          ]
      }
    end

    def province_is_valid
      unless valid_province?
        errors.add(:province, _('Please enter a valid province'))
      end
    end
  end
end
