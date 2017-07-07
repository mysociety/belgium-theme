# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do
  # Example adding an instance variable to the frontpage controller
  # GeneralController.class_eval do
  #   def mycontroller
  #     @say_something = "Greetings friend"
  #   end
  # end
  # Example adding a new action to an existing controller
  # HelpController.class_eval do
  #   def help_out
  #   end
  # end

  HelpController.class_eval do
    def conditions
      @contact_email = AlaveteliConfiguration::contact_email
    end

    def cada
      @contact_email = AlaveteliConfiguration::contact_email
    end
  end

  UserController.class_eval do
    def signchangeprovince
      if !authenticated?(
        :web => _('To change your province used on {{site_name}}',
                  :site_name => site_name),
        :email => _('Then you can change your province used on {{site_name}}',
                    :site_name => site_name),
        :email_subject => _('Change your province used on {{site_name}}',
                            :site_name => site_name)
        )
        # "authenticated?" has done the redirect to signin page for us
        return
      end

      if !params[:submitted_signchangeprovince_do]
        render :action => 'signchangeprovince'
        return
      else
        @user.province = params[:signchangeprovince][:province]
        if not @user.valid?
          @signchangeprovince = @user
          render :action => 'signchangeprovince'
        else
          @user.save!
          # Now clear the circumstance
          flash[:notice] = _('You have now changed your province used on ' \
                             '{{site_name}}',
                             :site_name => site_name)
          redirect_to user_url(@user)
        end
      end
    end

    def signchangepostcode
      if !authenticated?(
        :web => _('To change your postcode used on {{site_name}}',
                  :site_name => site_name),
        :email => _('Then you can change your postcode used on {{site_name}}',
                    :site_name => site_name),
        :email_subject => _('Change your postcode used on {{site_name}}',
                            :site_name => site_name)
        )
        # "authenticated?" has done the redirect to signin page for us
        return
      end

      if !params[:submitted_signchangepostcode_do]
        render :action => 'signchangepostcode'
        return
      else
        @user.postcode = params[:signchangepostcode][:postcode]
        if not @user.valid?
          @signchangeprovince = @user
          render :action => 'signchangepostcode'
        else
          @user.save!
          # Now clear the circumstance
          flash[:notice] = _('You have now changed your postcode used on ' \
                             '{{site_name}}',
                             :site_name => site_name)
          redirect_to user_url(@user)
        end
      end
    end

    # Add our extra params to the sanitized list allowed at signup
    def user_params(key = :user)
      params.require(key).permit(:name, :email, :password,
                                 :password_confirmation, :province, :postcode)
    end
  end
end
