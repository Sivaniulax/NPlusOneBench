# == Schema Information
#
# Table name: order
#
#  order_id    :bigint, not null, primary key
#  account_id  :bigint
#  bank_to     :text
#  account_to  :bigint
#  amount      :real
#  k_symbol    :text
#
class Order < ApplicationRecord
  self.table_name = "order"
  self.primary_key = "order_id"

  belongs_to :account, class_name: "Account", foreign_key: "account_id", optional: true
end
