# == Schema Information
#
# Table name: tags
#
#  id             :bigint, not null, primary key
#  tagname        :text
#  count          :bigint
#  excerptpostid  :bigint
#  wikipostid     :bigint
#
class Tag < ApplicationRecord
  self.table_name = "tags"

  belongs_to :excerptpost, class_name: "Post", foreign_key: "excerptpostid", optional: true
end
