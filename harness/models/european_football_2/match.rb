# == Schema Information
#
# Table name: match
#
#  id                :bigint, not null, primary key
#  country_id        :bigint
#  league_id         :bigint
#  season            :text
#  stage             :bigint
#  date              :text
#  match_api_id      :bigint
#  home_team_api_id  :bigint
#  away_team_api_id  :bigint
#  home_team_goal    :bigint
#  away_team_goal    :bigint
#  home_player_x1    :bigint
#  home_player_x2    :bigint
#  home_player_x3    :bigint
#  home_player_x4    :bigint
#  home_player_x5    :bigint
#  home_player_x6    :bigint
#  home_player_x7    :bigint
#  home_player_x8    :bigint
#  home_player_x9    :bigint
#  home_player_x10   :bigint
#  home_player_x11   :bigint
#  away_player_x1    :bigint
#  away_player_x2    :bigint
#  away_player_x3    :bigint
#  away_player_x4    :bigint
#  away_player_x5    :bigint
#  away_player_x6    :bigint
#  away_player_x7    :bigint
#  away_player_x8    :bigint
#  away_player_x9    :bigint
#  away_player_x10   :bigint
#  away_player_x11   :bigint
#  home_player_y1    :bigint
#  home_player_y2    :bigint
#  home_player_y3    :bigint
#  home_player_y4    :bigint
#  home_player_y5    :bigint
#  home_player_y6    :bigint
#  home_player_y7    :bigint
#  home_player_y8    :bigint
#  home_player_y9    :bigint
#  home_player_y10   :bigint
#  home_player_y11   :bigint
#  away_player_y1    :bigint
#  away_player_y2    :bigint
#  away_player_y3    :bigint
#  away_player_y4    :bigint
#  away_player_y5    :bigint
#  away_player_y6    :bigint
#  away_player_y7    :bigint
#  away_player_y8    :bigint
#  away_player_y9    :bigint
#  away_player_y10   :bigint
#  away_player_y11   :bigint
#  home_player_1     :bigint
#  home_player_2     :bigint
#  home_player_3     :bigint
#  home_player_4     :bigint
#  home_player_5     :bigint
#  home_player_6     :bigint
#  home_player_7     :bigint
#  home_player_8     :bigint
#  home_player_9     :bigint
#  home_player_10    :bigint
#  home_player_11    :bigint
#  away_player_1     :bigint
#  away_player_2     :bigint
#  away_player_3     :bigint
#  away_player_4     :bigint
#  away_player_5     :bigint
#  away_player_6     :bigint
#  away_player_7     :bigint
#  away_player_8     :bigint
#  away_player_9     :bigint
#  away_player_10    :bigint
#  away_player_11    :bigint
#  goal              :text
#  shoton            :text
#  shotoff           :text
#  foulcommit        :text
#  card              :text
#  cross             :text
#  corner            :text
#  possession        :text
#  b365h             :real
#  b365d             :real
#  b365a             :real
#  bwh               :real
#  bwd               :real
#  bwa               :real
#  iwh               :real
#  iwd               :real
#  iwa               :real
#  lbh               :real
#  lbd               :real
#  lba               :real
#  psh               :real
#  psd               :real
#  psa               :real
#  whh               :real
#  whd               :real
#  wha               :real
#  sjh               :real
#  sjd               :real
#  sja               :real
#  vch               :real
#  vcd               :real
#  vca               :real
#  gbh               :real
#  gbd               :real
#  gba               :real
#  bsh               :real
#  bsd               :real
#  bsa               :real
#
class Match < ApplicationRecord
  self.table_name = "match"

  belongs_to :away_team, class_name: "Team", foreign_key: "away_team_api_id", primary_key: "team_api_id", optional: true
  belongs_to :home_team, class_name: "Team", foreign_key: "home_team_api_id", primary_key: "team_api_id", optional: true
  belongs_to :league, class_name: "League", foreign_key: "league_id", optional: true
  belongs_to :country, class_name: "Country", foreign_key: "country_id", optional: true
  belongs_to :away_player_11_player, class_name: "Player", foreign_key: "away_player_11", primary_key: "player_api_id", optional: true
  belongs_to :away_player_10_player, class_name: "Player", foreign_key: "away_player_10", primary_key: "player_api_id", optional: true
  belongs_to :away_player_9_player, class_name: "Player", foreign_key: "away_player_9", primary_key: "player_api_id", optional: true
  belongs_to :away_player_8_player, class_name: "Player", foreign_key: "away_player_8", primary_key: "player_api_id", optional: true
  belongs_to :away_player_7_player, class_name: "Player", foreign_key: "away_player_7", primary_key: "player_api_id", optional: true
  belongs_to :away_player_6_player, class_name: "Player", foreign_key: "away_player_6", primary_key: "player_api_id", optional: true
  belongs_to :away_player_5_player, class_name: "Player", foreign_key: "away_player_5", primary_key: "player_api_id", optional: true
  belongs_to :away_player_4_player, class_name: "Player", foreign_key: "away_player_4", primary_key: "player_api_id", optional: true
  belongs_to :away_player_3_player, class_name: "Player", foreign_key: "away_player_3", primary_key: "player_api_id", optional: true
  belongs_to :away_player_2_player, class_name: "Player", foreign_key: "away_player_2", primary_key: "player_api_id", optional: true
  belongs_to :away_player_1_player, class_name: "Player", foreign_key: "away_player_1", primary_key: "player_api_id", optional: true
  belongs_to :home_player_11_player, class_name: "Player", foreign_key: "home_player_11", primary_key: "player_api_id", optional: true
  belongs_to :home_player_10_player, class_name: "Player", foreign_key: "home_player_10", primary_key: "player_api_id", optional: true
  belongs_to :home_player_9_player, class_name: "Player", foreign_key: "home_player_9", primary_key: "player_api_id", optional: true
  belongs_to :home_player_8_player, class_name: "Player", foreign_key: "home_player_8", primary_key: "player_api_id", optional: true
  belongs_to :home_player_7_player, class_name: "Player", foreign_key: "home_player_7", primary_key: "player_api_id", optional: true
  belongs_to :home_player_6_player, class_name: "Player", foreign_key: "home_player_6", primary_key: "player_api_id", optional: true
  belongs_to :home_player_5_player, class_name: "Player", foreign_key: "home_player_5", primary_key: "player_api_id", optional: true
  belongs_to :home_player_4_player, class_name: "Player", foreign_key: "home_player_4", primary_key: "player_api_id", optional: true
  belongs_to :home_player_3_player, class_name: "Player", foreign_key: "home_player_3", primary_key: "player_api_id", optional: true
  belongs_to :home_player_2_player, class_name: "Player", foreign_key: "home_player_2", primary_key: "player_api_id", optional: true
  belongs_to :home_player_1_player, class_name: "Player", foreign_key: "home_player_1", primary_key: "player_api_id", optional: true
end
