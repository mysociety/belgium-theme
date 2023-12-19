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

  RequestController.class_eval do
    # Note that the rendered file is cached, so clear the cached version
    # if you update this code!
    def download_entire_request_saisine
      @info_request = InfoRequest.find_by_url_title!(params[:url_title])
      # Check for access and hide embargoed requests immediately, so that we
      # don't leak any info to people who can't access them
      render_hidden if @info_request.embargo && cannot?(:read, @info_request)
      if !authenticated?
        ask_to_login(
          web: _('To download the zip file'),
          email: _('Then you can download a zip file of ' \
                   '{{info_request_title}}.',
                   info_request_title: @info_request.title),
          email_subject: _('Log in to download a zip file of ' \
                           '{{info_request_title}}',
                           info_request_title: @info_request.title)
        )
      else
        # Test for whole request being hidden or requester-only
        return render_hidden if cannot?(:read, @info_request)

        cache_file_path = @info_request.make_zip_cache_path_for_saisine(@user)
        unless File.exist?(cache_file_path)
          FileUtils.mkdir_p(File.dirname(cache_file_path))
          make_request_zip_for_saisine(@info_request, cache_file_path)
          File.chmod(0o644, cache_file_path)
        end
        send_file(cache_file_path, filename: "saisine_cada_#{params[:url_title]}.zip")
      end
    end

    def make_request_zip_for_saisine(info_request, file_path)
      Zip::File.open(file_path, create: true) do |zipfile|
        file_info = make_request_summary_file_for_saisine(info_request)
        zipfile.get_output_stream(file_info[:filename]) { |f| f.write(file_info[:data]) }
        message_index = 0
        info_request.incoming_messages.each do |message|
          next unless can?(:read, message)

          message_index += 1
          message.get_attachments_for_display.each do |attachment|
            filename = "#{message_index}_#{attachment.url_part_number}_#{attachment.display_filename}"
            zipfile.get_output_stream(filename) do |f|
              body = message.apply_masks(attachment.default_body, attachment.content_type)
              f.write(body)
            end
          end
        end
      end
    end

    def make_request_summary_file_for_saisine(info_request)
      done = false
      @render_to_file = true
      assign_variables_for_show_template(info_request)
      if HTMLtoPDFConverter.exist?
        html_output = render_to_string(template: 'request/show', variant: :cada)
        tmp_input = Tempfile.new(['foihtml2pdf-input', '.html'])
        tmp_input.write(html_output)
        tmp_input.close
        tmp_output = Tempfile.new('foihtml2pdf-output')
        command = HTMLtoPDFConverter.new(tmp_input, tmp_output)
        output = command.run
        if !output.nil?
          file_info = { filename: "correspondance_#{info_request.url_title}.pdf",
                        data: File.open(tmp_output.path).read }
          done = true
        else
          logger.error("Could not convert info request #{info_request.id} to PDF with command '#{command}'")
        end
        tmp_output.close
        tmp_input.delete
        tmp_output.delete
      else
        logger.warn('No HTML -> PDF converter found')
      end
      unless done
        file_info = { filename: 'correspondance.txt',
                      data: render_to_string(template: 'request/show',
                                             layout: false,
                                             formats: [:text]) }
      end
      file_info
    end
  end
end
