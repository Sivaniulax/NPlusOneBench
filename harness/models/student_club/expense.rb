# == Schema Information
#
# Table name: expense
#
#  expense_id           :text, not null, primary key
#  expense_description  :text
#  expense_date         :text
#  cost                 :real
#  approved             :text
#  link_to_member       :text
#  link_to_budget       :text
#
class Expense < ApplicationRecord
  self.table_name = "expense"
  self.primary_key = "expense_id"

  belongs_to :member, class_name: "Member", foreign_key: "link_to_member", optional: true
  belongs_to :budget, class_name: "Budget", foreign_key: "link_to_budget", optional: true
end
