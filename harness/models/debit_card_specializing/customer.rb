# == Schema Information
#
# Table name: customers
#
#  customerid  :bigint, not null, primary key
#  segment     :text
#  currency    :text
#
class Customer < ApplicationRecord
  self.table_name = "customers"
  self.primary_key = "customerid"

  has_many :year_months, class_name: "YearMonth", foreign_key: "customerid"
end
