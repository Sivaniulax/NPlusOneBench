# == Schema Information
#
# Table name: team
#
#  id                :bigint, not null, primary key
#  team_api_id       :bigint
#  team_fifa_api_id  :bigint
#  team_long_name    :text
#  team_short_name   :text
#
class Team < ApplicationRecord
  self.table_name = "team"

  has_many :team_attributes_as_team, class_name: "TeamAttribute", foreign_key: "team_api_id", primary_key: "team_api_id"
  has_many :team_attributes_as_team_fifa, class_name: "TeamAttribute", foreign_key: "team_fifa_api_id", primary_key: "team_fifa_api_id"
  has_many :matches_as_away_team, class_name: "Match", foreign_key: "away_team_api_id", primary_key: "team_api_id"
  has_many :matches_as_home_team, class_name: "Match", foreign_key: "home_team_api_id", primary_key: "team_api_id"
end
