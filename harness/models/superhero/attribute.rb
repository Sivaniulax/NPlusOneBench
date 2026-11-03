# == Schema Information
#
# Table name: attribute
#
#  id              :bigint, not null, primary key
#  attribute_name  :text
#
class Attribute < ApplicationRecord
  self.table_name = "attribute"

  has_many :hero_attributes, class_name: "HeroAttribute", foreign_key: "attribute_id"
end
