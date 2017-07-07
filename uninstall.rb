# -*- encoding : utf-8 -*-
# Uninstall hook code here

def table_exists?(table)
  ActiveRecord::Base.connection.table_exists?(table)
end

def column_exists?(table, column)
  if table_exists?(table)
    ActiveRecord::Base.connection.column_exists?(table, column)
  end
end

if ENV['REMOVE_MIGRATIONS']
  # Remove the postcode and province fields from the User model
  if column_exists?(:users, :postcode)
    file_path = '../db/migrate/belgium_theme_add_postcode_and_province_to_user'
    require File.expand_path file_path, __FILE__
    BelgiumThemeAddPostcodeAndProvinceToUser.down
  end
end
