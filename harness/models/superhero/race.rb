# == Schema Information
#
# Table name: race
#
#  id    :bigint, not null, primary key
#  race  :text
#
class Race < ApplicationRecord
  self.table_name = "race"

  has_many :superheros, class_name: "Superhero", foreign_key: "race_id"
end
