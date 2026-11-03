# == Schema Information
#
# Table name: team_attributes
#
#  id                              :bigint, not null, primary key
#  team_fifa_api_id                :bigint
#  team_api_id                     :bigint
#  date                            :text
#  buildupplayspeed                :bigint
#  buildupplayspeedclass           :text
#  buildupplaydribbling            :bigint
#  buildupplaydribblingclass       :text
#  buildupplaypassing              :bigint
#  buildupplaypassingclass         :text
#  buildupplaypositioningclass     :text
#  chancecreationpassing           :bigint
#  chancecreationpassingclass      :text
#  chancecreationcrossing          :bigint
#  chancecreationcrossingclass     :text
#  chancecreationshooting          :bigint
#  chancecreationshootingclass     :text
#  chancecreationpositioningclass  :text
#  defencepressure                 :bigint
#  defencepressureclass            :text
#  defenceaggression               :bigint
#  defenceaggressionclass          :text
#  defenceteamwidth                :bigint
#  defenceteamwidthclass           :text
#  defencedefenderlineclass        :text
#
class TeamAttribute < ApplicationRecord
  self.table_name = "team_attributes"

  belongs_to :team, class_name: "Team", foreign_key: "team_api_id", primary_key: "team_api_id", optional: true
  belongs_to :team_fifa, class_name: "Team", foreign_key: "team_fifa_api_id", primary_key: "team_fifa_api_id", optional: true
end
