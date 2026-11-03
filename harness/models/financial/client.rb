# == Schema Information
#
# Table name: client
#
#  client_id    :bigint, not null, primary key
#  gender       :text
#  birth_date   :date
#  district_id  :bigint
#
class Client < ApplicationRecord
  self.table_name = "client"
  self.primary_key = "client_id"

  belongs_to :district, class_name: "District", foreign_key: "district_id", optional: true
  has_many :disps, class_name: "Disp", foreign_key: "client_id"
end
