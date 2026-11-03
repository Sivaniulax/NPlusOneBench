# == Schema Information
#
# Table name: posts
#
#  id                     :bigint, not null, primary key
#  posttypeid             :bigint
#  acceptedanswerid       :bigint
#  creaiondate            :timestamp with time zone
#  score                  :bigint
#  viewcount              :bigint
#  body                   :text
#  owneruserid            :bigint
#  lasactivitydate        :timestamp with time zone
#  title                  :text
#  tags                   :text
#  answercount            :bigint
#  commentcount           :bigint
#  favoritecount          :bigint
#  lasteditoruserid       :bigint
#  lasteditdate           :timestamp with time zone
#  communityowneddate     :timestamp with time zone
#  parentid               :bigint
#  closeddate             :timestamp with time zone
#  ownerdisplayname       :text
#  lasteditordisplayname  :text
#
class Post < ApplicationRecord
  self.table_name = "posts"

  belongs_to :parent, class_name: "Post", foreign_key: "parentid", optional: true
  belongs_to :owneruser, class_name: "User", foreign_key: "owneruserid", optional: true
  belongs_to :lasteditoruser, class_name: "User", foreign_key: "lasteditoruserid", optional: true
  has_many :comments, class_name: "Comment", foreign_key: "postid"
  has_many :post_histories, class_name: "PostHistory", foreign_key: "postid"
  has_many :post_links_as_relatedpost, class_name: "PostLink", foreign_key: "relatedpostid"
  has_many :post_links_as_post, class_name: "PostLink", foreign_key: "postid"
  has_many :child_posts, class_name: "Post", foreign_key: "parentid"
  has_many :tags, class_name: "Tag", foreign_key: "excerptpostid"
  has_many :votes, class_name: "Vote", foreign_key: "postid"
end
