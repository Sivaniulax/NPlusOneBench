# == Schema Information
#
# Table name: postlinks
#
#  id             :bigint, not null, primary key
#  creationdate   :timestamp with time zone
#  postid         :bigint
#  relatedpostid  :bigint
#  linktypeid     :bigint
#
class PostLink < ApplicationRecord
  self.table_name = "postlinks"

  belongs_to :relatedpost, class_name: "Post", foreign_key: "relatedpostid", optional: true
  belongs_to :post, class_name: "Post", foreign_key: "postid", optional: true
end
