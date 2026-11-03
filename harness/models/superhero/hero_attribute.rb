# == Schema Information
#
# Table name: hero_attribute
#
#  hero_id          :bigint
#  attribute_id     :bigint
#  attribute_value  :bigint
#
class HeroAttribute < ApplicationRecord
  self.table_name = "hero_attribute"
  # no primary key in the source data

  belongs_to :hero, class_name: "Superhero", foreign_key: "hero_id", optional: true
  belongs_to :attribute, class_name: "Attribute", foreign_key: "attribute_id", optional: true
end
