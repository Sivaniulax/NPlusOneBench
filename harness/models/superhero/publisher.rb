# == Schema Information
#
# Table name: publisher
#
#  id              :bigint, not null, primary key
#  publisher_name  :text
#
class Publisher < ApplicationRecord
  self.table_name = "publisher"

  has_many :superheros, class_name: "Superhero", foreign_key: "publisher_id"
end
