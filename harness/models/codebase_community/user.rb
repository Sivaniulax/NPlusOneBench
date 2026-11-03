# == Schema Information
#
# Table name: users
#
#  id               :bigint, not null, primary key
#  reputation       :bigint
#  creationdate     :timestamp with time zone
#  displayname      :text
#  lastaccessdate   :timestamp with time zone
#  websiteurl       :text
#  location         :text
#  aboutme          :text
#  views            :bigint
#  upvotes          :bigint
#  downvotes        :bigint
#  accountid        :bigint
#  age              :bigint
#  profileimageurl  :text
#
class User < ApplicationRecord
  self.table_name = "users"

  has_many :badges, class_name: "Badge", foreign_key: "userid"
  has_many :comments, class_name: "Comment", foreign_key: "userid"
  has_many :post_histories, class_name: "PostHistory", foreign_key: "userid"
  has_many :posts_as_owneruser, class_name: "Post", foreign_key: "owneruserid"
  has_many :posts_as_lasteditoruser, class_name: "Post", foreign_key: "lasteditoruserid"
  has_many :votes, class_name: "Vote", foreign_key: "userid"
end
