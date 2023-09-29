# -*- encoding : utf-8 -*-
# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do
  module AnalyticsEvent
    module Action
      YOUTUBE_EXIT = 'YouTube Exit'
    end
  end

  # Example of adding a default text to each message
  # OutgoingMessage.class_eval do
  #   # Add intro paragraph to new request template
  #   def default_letter
  #     return nil if self.message_type == 'followup'
  #     "If you uncomment this line, this text will appear as default text in every message"
  #   end
  # end
  #
  InfoRequest.class_eval do
    def make_zip_cache_path_for_saisine(user)
      # This method is only used for the saisine CADA PDF doc.
      # The filename needs to be different from the "regular" PDF as the content
      # of this one is different. This prevents the cache from returning the wrong
      # file, should users request both files.
      # The zip file varies depending on user because it can include different
      # messages depending on whether the user can access hidden or
      # requester_only messages. We name it appropriately, so that every user
      # with the right permissions gets a file with only the right things in it.
      cache_file_dir = File.join(InfoRequest.download_zip_dir,
                                 'download',
                                 request_dirs,
                                 last_update_hash)
      cache_file_suffix = zip_cache_file_suffix(user)
      File.join(cache_file_dir, "saisine_#{url_title}#{cache_file_suffix}.zip")
    end

    # extra translation that will not appear in transifex
    def link_text_for_appeal_document
      if FastGettext.locale == 'nl_BE'
        'Download een zip bestand (voor een beroep bij CTB)'
      else
        'Télécharger un fichier zip pour votre recours CADA'
      end
    end
  end

  User.class_eval do
    strip_attributes only: [:province, :postcode]

    validates_presence_of :province,
                          :on => :create,
                          :message => _('Please select the province you ' \
                                        'live in')

    validate :province_not_removed, :on => :update

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

    # The "internal admin" is a special user for internal use.
    def self.internal_admin_user
      user = User.find_by_email(AlaveteliConfiguration::contact_email)
      if user.nil?
        password = PostRedirect.generate_random_token
        user = User.new(
          :name => 'Internal admin user',
          :email => AlaveteliConfiguration.contact_email,
          :password => password,
          :password_confirmation => password,
          :province => 'Bruxelles'
        )
        user.save!
      end

      user
    end

    private

    def province_not_removed
      if !province_was.blank? && province.blank?
        errors.add(:province, _('Please select the province you live in'))
      end
    end

  end
end
