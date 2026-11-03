# == Schema Information
#
# Table name: driverstandings
#
#  driverstandingsid  :bigint, not null, primary key
#  raceid             :bigint
#  driverid           :bigint
#  points             :real
#  position           :bigint
#  positiontext       :text
#  wins               :bigint
#
class DriverStanding < ApplicationRecord
  self.table_name = "driverstandings"
  self.primary_key = "driverstandingsid"

  belongs_to :driver, class_name: "Driver", foreign_key: "driverid", optional: true
  belongs_to :race, class_name: "Race", foreign_key: "raceid", optional: true
end
