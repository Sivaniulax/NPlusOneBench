# == Schema Information
#
# Table name: yearmonth
#
#  customerid   :bigint, primary key
#  date         :text, primary key
#  consumption  :real
#
class YearMonth < ApplicationRecord
  self.table_name = "yearmonth"
  self.primary_key = ["date", "customerid"]

  belongs_to :customer, class_name: "Customer", foreign_key: "customerid", optional: true
end
