# == Schema Information
#
# Table name: constructorstandings
#
#  constructorstandingsid  :bigint, not null, primary key
#  raceid                  :bigint
#  constructorid           :bigint
#  points                  :real
#  position                :bigint
#  positiontext            :text
#  wins                    :bigint
#
class ConstructorStanding < ApplicationRecord
  self.table_name = "constructorstandings"
  self.primary_key = "constructorstandingsid"

  belongs_to :constructor, class_name: "Constructor", foreign_key: "constructorid", optional: true
  belongs_to :race, class_name: "Race", foreign_key: "raceid", optional: true
end
