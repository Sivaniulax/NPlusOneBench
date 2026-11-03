# == Schema Information
#
# Table name: drivers
#
#  driverid     :bigint, not null, primary key
#  driverref    :text
#  number       :bigint
#  code         :text
#  forename     :text
#  surname      :text
#  dob          :date
#  nationality  :text
#  url          :text
#
class Driver < ApplicationRecord
  self.table_name = "drivers"
  self.primary_key = "driverid"

  has_many :driver_standings, class_name: "DriverStanding", foreign_key: "driverid"
  has_many :lap_times, class_name: "LapTime", foreign_key: "driverid"
  has_many :pit_stops, class_name: "PitStop", foreign_key: "driverid"
  has_many :qualifyings, class_name: "Qualifying", foreign_key: "driverid"
  has_many :results, class_name: "Result", foreign_key: "driverid"
end
