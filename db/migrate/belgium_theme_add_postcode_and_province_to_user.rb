# -*- encoding : utf-8 -*-
class BelgiumThemeAddPostcodeAndProvinceToUser < ActiveRecord::Migration[4.2]
  def self.up
    add_column :users, :postcode, :string
    add_column :users, :province, :string
  end

  def self.down
    remove_column :users, :postcode
    remove_column :users, :province
  end
end
