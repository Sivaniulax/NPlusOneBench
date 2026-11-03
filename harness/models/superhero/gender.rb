# == Schema Information
#
# Table name: gender
#
#  id      :bigint, not null, primary key
#  gender  :text
#
class Gender < ApplicationRecord
  self.table_name = "gender"

  has_many :superheros, class_name: "Superhero", foreign_key: "gender_id"
end
