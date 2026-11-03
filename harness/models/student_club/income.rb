# == Schema Information
#
# Table name: income
#
#  income_id       :text, not null, primary key
#  date_received   :text
#  amount          :bigint
#  source          :text
#  notes           :text
#  link_to_member  :text
#
class Income < ApplicationRecord
  self.table_name = "income"
  self.primary_key = "income_id"

  belongs_to :member, class_name: "Member", foreign_key: "link_to_member", optional: true
end
