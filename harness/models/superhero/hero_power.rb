# == Schema Information
#
# Table name: hero_power
#
#  hero_id   :bigint
#  power_id  :bigint
#
class HeroPower < ApplicationRecord
  self.table_name = "hero_power"
  # no primary key in the source data

  belongs_to :power, class_name: "Superpower", foreign_key: "power_id", optional: true
  belongs_to :hero, class_name: "Superhero", foreign_key: "hero_id", optional: true
end
