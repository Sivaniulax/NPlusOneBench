# == Schema Information
#
# Table name: card
#
#  card_id  :bigint, not null, primary key
#  disp_id  :bigint
#  type     :text
#  issued   :date
#
class Card < ApplicationRecord
  self.table_name = "card"
  self.primary_key = "card_id"

  belongs_to :disp, class_name: "Disp", foreign_key: "disp_id", optional: true
end
