# == Schema Information
#
# Table name: event
#
#  event_id    :text, not null, primary key
#  event_name  :text
#  event_date  :text
#  type        :text
#  notes       :text
#  location    :text
#  status      :text
#
class Event < ApplicationRecord
  self.table_name = "event"
  self.primary_key = "event_id"

  has_many :attendances, class_name: "Attendance", foreign_key: "link_to_event"
  has_many :budgets, class_name: "Budget", foreign_key: "link_to_event"
end
