# == Schema Information
#
# Table name: major
#
#  major_id    :text, not null, primary key
#  major_name  :text
#  department  :text
#  college     :text
#
class Major < ApplicationRecord
  self.table_name = "major"
  self.primary_key = "major_id"

  has_many :members, class_name: "Member", foreign_key: "link_to_major"
end
