# == Schema Information
#
# Table name: foreign_data
#
#  id            :bigint, not null, primary key
#  flavortext    :text
#  language      :text
#  multiverseid  :bigint
#  name          :text
#  text          :text
#  type          :text
#  uuid          :text
#
class ForeignData < ApplicationRecord
  self.table_name = "foreign_data"

  belongs_to :card, class_name: "Card", foreign_key: "uuid", primary_key: "uuid", optional: true
end
