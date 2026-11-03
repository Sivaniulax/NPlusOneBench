# == Schema Information
#
# Table name: laptimes
#
#  raceid        :bigint, not null, primary key
#  driverid      :bigint, not null, primary key
#  lap           :bigint, not null, primary key
#  position      :bigint
#  time          :text
#  milliseconds  :bigint
#
class LapTime < ApplicationRecord
  self.table_name = "laptimes"
  self.primary_key = ["raceid", "driverid", "lap"]

  belongs_to :driver, class_name: "Driver", foreign_key: "driverid", optional: true
  belongs_to :race, class_name: "Race", foreign_key: "raceid", optional: true
end
