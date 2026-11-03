# == Schema Information
#
# Table name: races
#
#  raceid     :bigint, not null, primary key
#  year       :bigint
#  round      :bigint
#  circuitid  :bigint
#  name       :text
#  date       :date
#  time       :text
#  url        :text
#
class Race < ApplicationRecord
  self.table_name = "races"
  self.primary_key = "raceid"

  belongs_to :circuit, class_name: "Circuit", foreign_key: "circuitid", optional: true
  belongs_to :season, class_name: "Season", foreign_key: "year", optional: true
  has_many :constructor_results, class_name: "ConstructorResult", foreign_key: "raceid"
  has_many :constructor_standings, class_name: "ConstructorStanding", foreign_key: "raceid"
  has_many :driver_standings, class_name: "DriverStanding", foreign_key: "raceid"
  has_many :lap_times, class_name: "LapTime", foreign_key: "raceid"
  has_many :pit_stops, class_name: "PitStop", foreign_key: "raceid"
  has_many :qualifyings, class_name: "Qualifying", foreign_key: "raceid"
  has_many :results, class_name: "Result", foreign_key: "raceid"
end
