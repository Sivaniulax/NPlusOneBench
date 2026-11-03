# == Schema Information
#
# Table name: comments
#
#  id               :bigint, not null, primary key
#  postid           :bigint
#  score            :bigint
#  text             :text
#  creationdate     :timestamp with time zone
#  userid           :bigint
#  userdisplayname  :text
#
class Comment < ApplicationRecord
  self.table_name = "comments"

  belongs_to :user, class_name: "User", foreign_key: "userid", optional: true
  belongs_to :post, class_name: "Post", foreign_key: "postid", optional: true
end
