# == Schema Information
#
# Table name: budget
#
#  budget_id      :text, not null, primary key
#  category       :text
#  spent          :real
#  remaining      :real
#  amount         :bigint
#  event_status   :text
#  link_to_event  :text
#
class Budget < ApplicationRecord
  self.table_name = "budget"
  self.primary_key = "budget_id"

  belongs_to :event, class_name: "Event", foreign_key: "link_to_event", optional: true
  has_many :expenses, class_name: "Expense", foreign_key: "link_to_budget"
end
