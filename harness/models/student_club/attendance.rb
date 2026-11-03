# == Schema Information
#
# Table name: attendance
#
#  link_to_event   :text, not null, primary key
#  link_to_member  :text, not null, primary key
#
class Attendance < ApplicationRecord
  self.table_name = "attendance"
  self.primary_key = ["link_to_event", "link_to_member"]

  belongs_to :member, class_name: "Member", foreign_key: "link_to_member", optional: true
  belongs_to :event, class_name: "Event", foreign_key: "link_to_event", optional: true
end
