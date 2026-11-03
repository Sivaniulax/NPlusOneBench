# == Schema Information
#
# Table name: loan
#
#  loan_id     :bigint, not null, primary key
#  account_id  :bigint
#  date        :date
#  amount      :bigint
#  duration    :bigint
#  payments    :real
#  status      :text
#
class Loan < ApplicationRecord
  self.table_name = "loan"
  self.primary_key = "loan_id"

  belongs_to :account, class_name: "Account", foreign_key: "account_id", optional: true
end
