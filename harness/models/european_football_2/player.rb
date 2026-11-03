# == Schema Information
#
# Table name: player
#
#  id                  :bigint, not null, primary key
#  player_api_id       :bigint
#  player_name         :text
#  player_fifa_api_id  :bigint
#  birthday            :text
#  height              :bigint
#  weight              :bigint
#
class Player < ApplicationRecord
  self.table_name = "player"

  has_many :player_attributes_as_player, class_name: "PlayerAttribute", foreign_key: "player_api_id", primary_key: "player_api_id"
  has_many :player_attributes_as_player_fifa, class_name: "PlayerAttribute", foreign_key: "player_fifa_api_id", primary_key: "player_fifa_api_id"
  has_many :matches_as_away_player_11_player, class_name: "Match", foreign_key: "away_player_11", primary_key: "player_api_id"
  has_many :matches_as_away_player_10_player, class_name: "Match", foreign_key: "away_player_10", primary_key: "player_api_id"
  has_many :matches_as_away_player_9_player, class_name: "Match", foreign_key: "away_player_9", primary_key: "player_api_id"
  has_many :matches_as_away_player_8_player, class_name: "Match", foreign_key: "away_player_8", primary_key: "player_api_id"
  has_many :matches_as_away_player_7_player, class_name: "Match", foreign_key: "away_player_7", primary_key: "player_api_id"
  has_many :matches_as_away_player_6_player, class_name: "Match", foreign_key: "away_player_6", primary_key: "player_api_id"
  has_many :matches_as_away_player_5_player, class_name: "Match", foreign_key: "away_player_5", primary_key: "player_api_id"
  has_many :matches_as_away_player_4_player, class_name: "Match", foreign_key: "away_player_4", primary_key: "player_api_id"
  has_many :matches_as_away_player_3_player, class_name: "Match", foreign_key: "away_player_3", primary_key: "player_api_id"
  has_many :matches_as_away_player_2_player, class_name: "Match", foreign_key: "away_player_2", primary_key: "player_api_id"
  has_many :matches_as_away_player_1_player, class_name: "Match", foreign_key: "away_player_1", primary_key: "player_api_id"
  has_many :matches_as_home_player_11_player, class_name: "Match", foreign_key: "home_player_11", primary_key: "player_api_id"
  has_many :matches_as_home_player_10_player, class_name: "Match", foreign_key: "home_player_10", primary_key: "player_api_id"
  has_many :matches_as_home_player_9_player, class_name: "Match", foreign_key: "home_player_9", primary_key: "player_api_id"
  has_many :matches_as_home_player_8_player, class_name: "Match", foreign_key: "home_player_8", primary_key: "player_api_id"
  has_many :matches_as_home_player_7_player, class_name: "Match", foreign_key: "home_player_7", primary_key: "player_api_id"
  has_many :matches_as_home_player_6_player, class_name: "Match", foreign_key: "home_player_6", primary_key: "player_api_id"
  has_many :matches_as_home_player_5_player, class_name: "Match", foreign_key: "home_player_5", primary_key: "player_api_id"
  has_many :matches_as_home_player_4_player, class_name: "Match", foreign_key: "home_player_4", primary_key: "player_api_id"
  has_many :matches_as_home_player_3_player, class_name: "Match", foreign_key: "home_player_3", primary_key: "player_api_id"
  has_many :matches_as_home_player_2_player, class_name: "Match", foreign_key: "home_player_2", primary_key: "player_api_id"
  has_many :matches_as_home_player_1_player, class_name: "Match", foreign_key: "home_player_1", primary_key: "player_api_id"
end
