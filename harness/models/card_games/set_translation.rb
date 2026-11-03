# == Schema Information
#
# Table name: set_translations
#
#  id           :bigint, not null, primary key
#  language     :text
#  setcode      :text
#  translation  :text
#
class SetTranslation < ApplicationRecord
  self.table_name = "set_translations"

  belongs_to :set, class_name: "Set", foreign_key: "setcode", primary_key: "code", optional: true
end
