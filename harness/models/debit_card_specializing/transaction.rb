# == Schema Information
#
# Table name: transactions_1k
#
#  transactionid  :bigint, not null, primary key
#  date           :date
#  time           :text
#  customerid     :bigint
#  cardid         :bigint
#  gasstationid   :bigint
#  productid      :bigint
#  amount         :bigint
#  price          :real
#
class Transaction < ApplicationRecord
  self.table_name = "transactions_1k"
  self.primary_key = "transactionid"
end
