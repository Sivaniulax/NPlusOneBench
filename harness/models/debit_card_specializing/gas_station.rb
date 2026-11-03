# == Schema Information
#
# Table name: gasstations
#
#  gasstationid  :bigint, not null, primary key
#  chainid       :bigint
#  country       :text
#  segment       :text
#
class GasStation < ApplicationRecord
  self.table_name = "gasstations"
  self.primary_key = "gasstationid"
end
