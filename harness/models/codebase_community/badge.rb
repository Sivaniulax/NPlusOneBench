# == Schema Information
#
# Table name: badges
#
#  id      :bigint, not null, primary key
#  userid  :bigint
#  name    :text
#  date    :timestamp with time zone
#
class Badge < ApplicationRecord
  self.table_name = "badges"

  belongs_to :user, class_name: "User", foreign_key: "userid", optional: true
end
