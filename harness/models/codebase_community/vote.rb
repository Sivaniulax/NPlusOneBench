# == Schema Information
#
# Table name: votes
#
#  id            :bigint, not null, primary key
#  postid        :bigint
#  votetypeid    :bigint
#  creationdate  :date
#  userid        :bigint
#  bountyamount  :bigint
#
class Vote < ApplicationRecord
  self.table_name = "votes"

  belongs_to :user, class_name: "User", foreign_key: "userid", optional: true
  belongs_to :post, class_name: "Post", foreign_key: "postid", optional: true
end
