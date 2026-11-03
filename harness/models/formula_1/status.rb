# == Schema Information
#
# Table name: status
#
#  statusid  :bigint, not null, primary key
#  status    :text
#
class Status < ApplicationRecord
  self.table_name = "status"
  self.primary_key = "statusid"

  has_many :results, class_name: "Result", foreign_key: "statusid"
end
