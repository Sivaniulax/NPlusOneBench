# == Schema Information
#
# Table name: results
#
#  resultid         :bigint, not null, primary key
#  raceid           :bigint
#  driverid         :bigint
#  constructorid    :bigint
#  number           :bigint
#  grid             :bigint
#  position         :bigint
#  positiontext     :text
#  positionorder    :bigint
#  points           :real
#  laps             :bigint
#  time             :text
#  milliseconds     :bigint
#  fastestlap       :bigint
#  rank             :bigint
#  fastestlaptime   :text
#  fastestlapspeed  :text
#  statusid         :bigint
#
class Result < ApplicationRecord
  self.table_name = "results"
  self.primary_key = "resultid"

  belongs_to :status, class_name: "Status", foreign_key: "statusid", optional: true
  belongs_to :constructor, class_name: "Constructor", foreign_key: "constructorid", optional: true
  belongs_to :driver, class_name: "Driver", foreign_key: "driverid", optional: true
  belongs_to :race, class_name: "Race", foreign_key: "raceid", optional: true
end
