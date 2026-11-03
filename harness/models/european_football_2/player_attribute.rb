# == Schema Information
#
# Table name: player_attributes
#
#  id                   :bigint, not null, primary key
#  player_fifa_api_id   :bigint
#  player_api_id        :bigint
#  date                 :text
#  overall_rating       :bigint
#  potential            :bigint
#  preferred_foot       :text
#  attacking_work_rate  :text
#  defensive_work_rate  :text
#  crossing             :bigint
#  finishing            :bigint
#  heading_accuracy     :bigint
#  short_passing        :bigint
#  volleys              :bigint
#  dribbling            :bigint
#  curve                :bigint
#  free_kick_accuracy   :bigint
#  long_passing         :bigint
#  ball_control         :bigint
#  acceleration         :bigint
#  sprint_speed         :bigint
#  agility              :bigint
#  reactions            :bigint
#  balance              :bigint
#  shot_power           :bigint
#  jumping              :bigint
#  stamina              :bigint
#  strength             :bigint
#  long_shots           :bigint
#  aggression           :bigint
#  interceptions        :bigint
#  positioning          :bigint
#  vision               :bigint
#  penalties            :bigint
#  marking              :bigint
#  standing_tackle      :bigint
#  sliding_tackle       :bigint
#  gk_diving            :bigint
#  gk_handling          :bigint
#  gk_kicking           :bigint
#  gk_positioning       :bigint
#  gk_reflexes          :bigint
#
class PlayerAttribute < ApplicationRecord
  self.table_name = "player_attributes"

  belongs_to :player, class_name: "Player", foreign_key: "player_api_id", primary_key: "player_api_id", optional: true
  belongs_to :player_fifa, class_name: "Player", foreign_key: "player_fifa_api_id", primary_key: "player_fifa_api_id", optional: true
end
