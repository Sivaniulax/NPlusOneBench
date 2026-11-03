# == Schema Information
#
# Table name: member
#
#  member_id      :text, not null, primary key
#  first_name     :text
#  last_name      :text
#  email          :text
#  position       :text
#  t_shirt_size   :text
#  phone          :text
#  zip            :bigint
#  link_to_major  :text
#
class Member < ApplicationRecord
  self.table_name = "member"
  self.primary_key = "member_id"

  belongs_to :zip_code, class_name: "ZipCode", foreign_key: "zip", optional: true
  belongs_to :major, class_name: "Major", foreign_key: "link_to_major", optional: true
  has_many :attendances, class_name: "Attendance", foreign_key: "link_to_member"
  has_many :expenses, class_name: "Expense", foreign_key: "link_to_member"
  has_many :incomes, class_name: "Income", foreign_key: "link_to_member"
end
