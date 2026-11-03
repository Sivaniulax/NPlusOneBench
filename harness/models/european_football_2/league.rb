# == Schema Information
#
# Table name: league
#
#  id          :bigint, not null, primary key
#  country_id  :bigint
#  name        :text
#
class League < ApplicationRecord
  self.table_name = "league"

  belongs_to :country, class_name: "Country", foreign_key: "country_id", optional: true
  has_many :matches, class_name: "Match", foreign_key: "league_id"
end
