# == Schema Information
#
# Table name: zip_code
#
#  zip_code     :bigint, not null, primary key
#  type         :text
#  city         :text
#  county       :text
#  state        :text
#  short_state  :text
#
class ZipCode < ApplicationRecord
  self.table_name = "zip_code"
  self.primary_key = "zip_code"

  has_many :members, class_name: "Member", foreign_key: "zip"
end
