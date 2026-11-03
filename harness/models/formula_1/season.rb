# == Schema Information
#
# Table name: seasons
#
#  year  :bigint, not null, primary key
#  url   :text
#
class Season < ApplicationRecord
  self.table_name = "seasons"
  self.primary_key = "year"

  has_many :races, class_name: "Race", foreign_key: "year"
end
