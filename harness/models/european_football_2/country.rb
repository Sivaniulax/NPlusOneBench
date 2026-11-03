# == Schema Information
#
# Table name: country
#
#  id    :bigint, not null, primary key
#  name  :text
#
class Country < ApplicationRecord
  self.table_name = "country"

  has_many :leagues, class_name: "League", foreign_key: "country_id"
  has_many :matches, class_name: "Match", foreign_key: "country_id"
end
