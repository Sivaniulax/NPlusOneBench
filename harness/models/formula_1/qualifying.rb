# == Schema Information
#
# Table name: qualifying
#
#  qualifyid      :bigint, not null, primary key
#  raceid         :bigint
#  driverid       :bigint
#  constructorid  :bigint
#  number         :bigint
#  position       :bigint
#  q1             :text
#  q2             :text
#  q3             :text
#
class Qualifying < ApplicationRecord
  self.table_name = "qualifying"
  self.primary_key = "qualifyid"

  belongs_to :constructor, class_name: "Constructor", foreign_key: "constructorid", optional: true
  belongs_to :driver, class_name: "Driver", foreign_key: "driverid", optional: true
  belongs_to :race, class_name: "Race", foreign_key: "raceid", optional: true
end
