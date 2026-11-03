# == Schema Information
#
# Table name: schools
#
#  cdscode      :text, primary key
#  ncesdist     :text
#  ncesschool   :text
#  statustype   :text
#  county       :text
#  district     :text
#  school       :text
#  street       :text
#  streetabr    :text
#  city         :text
#  zip          :text
#  state        :text
#  mailstreet   :text
#  mailstrabr   :text
#  mailcity     :text
#  mailzip      :text
#  mailstate    :text
#  phone        :text
#  ext          :text
#  website      :text
#  opendate     :date
#  closeddate   :date
#  charter      :bigint
#  charternum   :text
#  fundingtype  :text
#  doc          :text
#  doctype      :text
#  soc          :text
#  soctype      :text
#  edopscode    :text
#  edopsname    :text
#  eilcode      :text
#  eilname      :text
#  gsoffered    :text
#  gsserved     :text
#  virtual      :text
#  magnet       :bigint
#  latitude     :real
#  longitude    :real
#  admfname1    :text
#  admlname1    :text
#  admemail1    :text
#  admfname2    :text
#  admlname2    :text
#  admemail2    :text
#  admfname3    :text
#  admlname3    :text
#  admemail3    :text
#  lastupdate   :date
#
class School < ApplicationRecord
  self.table_name = "schools"
  self.primary_key = "cdscode"

  has_many :frpms, class_name: "Frpm", foreign_key: "cdscode"
  has_many :satscores, class_name: "Satscore", foreign_key: "cds"
end
