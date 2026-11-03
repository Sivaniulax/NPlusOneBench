# == Schema Information
#
# Table name: patient
#
#  id           :bigint, not null, primary key
#  sex          :text
#  birthday     :date
#  description  :date
#  First Date   :date
#  admission    :text
#  diagnosis    :text
#
class Patient < ApplicationRecord
  self.table_name = "patient"

  alias_attribute :first_date, "First Date"

  has_many :examinations, class_name: "Examination", foreign_key: "id"
  has_many :laboratories, class_name: "Laboratory", foreign_key: "id"
end
