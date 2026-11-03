# == Schema Information
#
# Table name: alignment
#
#  id         :bigint, not null, primary key
#  alignment  :text
#
class Alignment < ApplicationRecord
  self.table_name = "alignment"

  has_many :superheros, class_name: "Superhero", foreign_key: "alignment_id"
end
