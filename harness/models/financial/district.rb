# == Schema Information
#
# Table name: district
#
#  district_id  :bigint, not null, primary key
#  a2           :text
#  a3           :text
#  a4           :text
#  a5           :text
#  a6           :text
#  a7           :text
#  a8           :bigint
#  a9           :bigint
#  a10          :real
#  a11          :bigint
#  a12          :real
#  a13          :real
#  a14          :bigint
#  a15          :bigint
#  a16          :bigint
#
class District < ApplicationRecord
  self.table_name = "district"
  self.primary_key = "district_id"

  has_many :accounts, class_name: "Account", foreign_key: "district_id"
  has_many :clients, class_name: "Client", foreign_key: "district_id"
end
