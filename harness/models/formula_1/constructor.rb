# == Schema Information
#
# Table name: constructors
#
#  constructorid   :bigint, not null, primary key
#  constructorref  :text
#  name            :text
#  nationality     :text
#  url             :text
#
class Constructor < ApplicationRecord
  self.table_name = "constructors"
  self.primary_key = "constructorid"

  has_many :constructor_results, class_name: "ConstructorResult", foreign_key: "constructorid"
  has_many :constructor_standings, class_name: "ConstructorStanding", foreign_key: "constructorid"
  has_many :qualifyings, class_name: "Qualifying", foreign_key: "constructorid"
  has_many :results, class_name: "Result", foreign_key: "constructorid"
end
