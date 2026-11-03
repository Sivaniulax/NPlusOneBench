# == Schema Information
#
# Table name: colour
#
#  id      :bigint, not null, primary key
#  colour  :text
#
class Colour < ApplicationRecord
  self.table_name = "colour"

  has_many :superheros_as_skin_colour, class_name: "Superhero", foreign_key: "skin_colour_id"
  has_many :superheros_as_hair_colour, class_name: "Superhero", foreign_key: "hair_colour_id"
  has_many :superheros_as_eye_colour, class_name: "Superhero", foreign_key: "eye_colour_id"
end
