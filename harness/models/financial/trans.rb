# == Schema Information
#
# Table name: trans
#
#  trans_id    :bigint, not null, primary key
#  account_id  :bigint
#  date        :date
#  type        :text
#  operation   :text
#  amount      :bigint
#  balance     :bigint
#  k_symbol    :text
#  bank        :text
#  account     :bigint
#
class Trans < ApplicationRecord
  self.table_name = "trans"
  self.primary_key = "trans_id"

  belongs_to :account_record, class_name: "Account", foreign_key: "account_id", optional: true
end
