# -*- encoding : utf-8 -*-
# This file is executed in the Rails evironment by the `rails-post-deploy`
# script

def table_exists?(table)
  ActiveRecord::Base.connection.table_exists?(table)
end

def column_exists?(table, column)
  if table_exists?(table)
    ActiveRecord::Base.connection.column_exists?(table, column)
  end
end

# Add the postcode and province fields to the User model
unless column_exists?(:users, :postcode)
  file_path = '../db/migrate/belgium_theme_add_postcode_and_province_to_user'
  require File.expand_path file_path, __FILE__
  BelgiumThemeAddPostcodeAndProvinceToUser.up
end
