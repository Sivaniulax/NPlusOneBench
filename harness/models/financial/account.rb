# == Schema Information
#
# Table name: account
#
#  account_id   :bigint, not null, primary key
#  district_id  :bigint
#  frequency    :text
#  date         :date
#
class Account < ApplicationRecord
  self.table_name = "account"
  self.primary_key = "account_id"

  belongs_to :district, class_name: "District", foreign_key: "district_id", optional: true
  has_many :disps, class_name: "Disp", foreign_key: "account_id"
  has_many :loans, class_name: "Loan", foreign_key: "account_id"
  has_many :orders, class_name: "Order", foreign_key: "account_id"
  has_many :trans, class_name: "Trans", foreign_key: "account_id"
end
