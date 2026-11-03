# == Schema Information
#
# Table name: superpower
#
#  id          :bigint, not null, primary key
#  power_name  :text
#
class Superpower < ApplicationRecord
  self.table_name = "superpower"

  has_many :hero_powers, class_name: "HeroPower", foreign_key: "power_id"
end
