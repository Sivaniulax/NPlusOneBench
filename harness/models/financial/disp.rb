# == Schema Information
#
# Table name: disp
#
#  disp_id     :bigint, not null, primary key
#  client_id   :bigint
#  account_id  :bigint
#  type        :text
#
class Disp < ApplicationRecord
  self.table_name = "disp"
  self.primary_key = "disp_id"

  belongs_to :client, class_name: "Client", foreign_key: "client_id", optional: true
  belongs_to :account, class_name: "Account", foreign_key: "account_id", optional: true
  has_many :cards, class_name: "Card", foreign_key: "disp_id"
end
