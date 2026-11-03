# == Schema Information
#
# Table name: posthistory
#
#  id                 :bigint, not null, primary key
#  posthistorytypeid  :bigint
#  postid             :bigint
#  revisionguid       :text
#  creationdate       :timestamp with time zone
#  userid             :bigint
#  text               :text
#  comment            :text
#  userdisplayname    :text
#
class PostHistory < ApplicationRecord
  self.table_name = "posthistory"

  belongs_to :user, class_name: "User", foreign_key: "userid", optional: true
  belongs_to :post, class_name: "Post", foreign_key: "postid", optional: true
end
