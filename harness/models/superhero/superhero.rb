# == Schema Information
#
# Table name: superhero
#
#  id              :bigint, not null, primary key
#  superhero_name  :text
#  full_name       :text
#  gender_id       :bigint
#  eye_colour_id   :bigint
#  hair_colour_id  :bigint
#  skin_colour_id  :bigint
#  race_id         :bigint
#  publisher_id    :bigint
#  alignment_id    :bigint
#  height_cm       :bigint
#  weight_kg       :bigint
#
class Superhero < ApplicationRecord
  self.table_name = "superhero"

  belongs_to :skin_colour, class_name: "Colour", foreign_key: "skin_colour_id", optional: true
  belongs_to :race, class_name: "Race", foreign_key: "race_id", optional: true
  belongs_to :publisher, class_name: "Publisher", foreign_key: "publisher_id", optional: true
  belongs_to :hair_colour, class_name: "Colour", foreign_key: "hair_colour_id", optional: true
  belongs_to :gender, class_name: "Gender", foreign_key: "gender_id", optional: true
  belongs_to :eye_colour, class_name: "Colour", foreign_key: "eye_colour_id", optional: true
  belongs_to :alignment, class_name: "Alignment", foreign_key: "alignment_id", optional: true
  has_many :hero_attributes, class_name: "HeroAttribute", foreign_key: "hero_id"
  has_many :hero_powers, class_name: "HeroPower", foreign_key: "hero_id"
end
