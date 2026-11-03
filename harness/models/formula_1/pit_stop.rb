# == Schema Information
#
# Table name: pitstops
#
#  raceid        :bigint, not null, primary key
#  driverid      :bigint, not null, primary key
#  stop          :bigint, not null, primary key
#  lap           :bigint
#  time          :text
#  duration      :text
#  milliseconds  :bigint
#
class PitStop < ApplicationRecord
  self.table_name = "pitstops"
  self.primary_key = ["raceid", "driverid", "stop"]

  belongs_to :driver, class_name: "Driver", foreign_key: "driverid", optional: true
  belongs_to :race, class_name: "Race", foreign_key: "raceid", optional: true
end
