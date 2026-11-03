# == Schema Information
#
# Table name: circuits
#
#  circuitid   :bigint, not null, primary key
#  circuitref  :text
#  name        :text
#  location    :text
#  country     :text
#  lat         :real
#  lng         :real
#  alt         :bigint
#  url         :text
#
class Circuit < ApplicationRecord
  self.table_name = "circuits"
  self.primary_key = "circuitid"

  has_many :races, class_name: "Race", foreign_key: "circuitid"
end
