# == Schema Information
#
# Table name: sets
#
#  id                :bigint, not null, primary key
#  basesetsize       :bigint
#  block             :text
#  booster           :text
#  code              :text
#  isfoilonly        :bigint
#  isforeignonly     :bigint
#  isnonfoilonly     :bigint
#  isonlineonly      :bigint
#  ispartialpreview  :bigint
#  keyrunecode       :text
#  mcmid             :bigint
#  mcmidextras       :bigint
#  mcmname           :text
#  mtgocode          :text
#  name              :text
#  parentcode        :text
#  releasedate       :date
#  tcgplayergroupid  :bigint
#  totalsetsize      :bigint
#  type              :text
#
class Set < ApplicationRecord
  self.table_name = "sets"

  has_many :set_translations, class_name: "SetTranslation", foreign_key: "setcode", primary_key: "code"
end
