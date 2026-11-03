# == Schema Information
#
# Table name: legalities
#
#  id      :bigint, not null, primary key
#  format  :text
#  status  :text
#  uuid    :text
#
class Legality < ApplicationRecord
  self.table_name = "legalities"

  belongs_to :card, class_name: "Card", foreign_key: "uuid", primary_key: "uuid", optional: true
end
