# == Schema Information
#
# Table name: rulings
#
#  id    :bigint, not null, primary key
#  date  :date
#  text  :text
#  uuid  :text
#
class Ruling < ApplicationRecord
  self.table_name = "rulings"

  belongs_to :card, class_name: "Card", foreign_key: "uuid", primary_key: "uuid", optional: true
end
