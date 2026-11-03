# == Schema Information
#
# Table name: satscores
#
#  cds          :text, not null, primary key
#  rtype        :text
#  sname        :text
#  dname        :text
#  cname        :text
#  enroll12     :bigint
#  numtsttakr   :bigint
#  avgscrread   :bigint
#  avgscrmath   :bigint
#  avgscrwrite  :bigint
#  numge1500    :bigint
#
class Satscore < ApplicationRecord
  self.table_name = "satscores"
  self.primary_key = "cds"

  belongs_to :school, class_name: "School", foreign_key: "cds", optional: true
end
