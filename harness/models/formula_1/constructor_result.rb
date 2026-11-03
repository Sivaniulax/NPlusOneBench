# == Schema Information
#
# Table name: constructorresults
#
#  constructorresultsid  :bigint, not null, primary key
#  raceid                :bigint
#  constructorid         :bigint
#  points                :real
#  status                :text
#
class ConstructorResult < ApplicationRecord
  self.table_name = "constructorresults"
  self.primary_key = "constructorresultsid"

  belongs_to :constructor, class_name: "Constructor", foreign_key: "constructorid", optional: true
  belongs_to :race, class_name: "Race", foreign_key: "raceid", optional: true
end
