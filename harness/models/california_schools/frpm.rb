# == Schema Information
#
# Table name: frpm
#
#  cdscode                                      :text, primary key
#  Academic Year                                :text
#  County Code                                  :text
#  District Code                                :bigint
#  School Code                                  :text
#  County Name                                  :text
#  District Name                                :text
#  School Name                                  :text
#  District Type                                :text
#  School Type                                  :text
#  Educational Option Type                      :text
#  NSLP Provision Status                        :text
#  Charter School (Y/N)                         :bigint
#  Charter School Number                        :text
#  Charter Funding Type                         :text
#  irc                                          :bigint
#  Low Grade                                    :text
#  High Grade                                   :text
#  Enrollment (K-12)                            :real
#  Free Meal Count (K-12)                       :real
#  Percent (%) Eligible Free (K-12)             :real
#  FRPM Count (K-12)                            :real
#  Percent (%) Eligible FRPM (K-12)             :real
#  Enrollment (Ages 5-17)                       :real
#  Free Meal Count (Ages 5-17)                  :real
#  Percent (%) Eligible Free (Ages 5-17)        :real
#  FRPM Count (Ages 5-17)                       :real
#  Percent (%) Eligible FRPM (Ages 5-17)        :real
#  2013-14 CALPADS Fall 1 Certification Status  :bigint
#
class Frpm < ApplicationRecord
  self.table_name = "frpm"
  self.primary_key = "cdscode"

  alias_attribute :academic_year, "Academic Year"
  alias_attribute :county_code, "County Code"
  alias_attribute :district_code, "District Code"
  alias_attribute :school_code, "School Code"
  alias_attribute :county_name, "County Name"
  alias_attribute :district_name, "District Name"
  alias_attribute :school_name, "School Name"
  alias_attribute :district_type, "District Type"
  alias_attribute :school_type, "School Type"
  alias_attribute :educational_option_type, "Educational Option Type"
  alias_attribute :nslp_provision_status, "NSLP Provision Status"
  alias_attribute :charter_school_y_n, "Charter School (Y/N)"
  alias_attribute :charter_school_number, "Charter School Number"
  alias_attribute :charter_funding_type, "Charter Funding Type"
  alias_attribute :low_grade, "Low Grade"
  alias_attribute :high_grade, "High Grade"
  alias_attribute :enrollment_k_12, "Enrollment (K-12)"
  alias_attribute :free_meal_count_k_12, "Free Meal Count (K-12)"
  alias_attribute :percent_eligible_free_k_12, "Percent (%) Eligible Free (K-12)"
  alias_attribute :frpm_count_k_12, "FRPM Count (K-12)"
  alias_attribute :percent_eligible_frpm_k_12, "Percent (%) Eligible FRPM (K-12)"
  alias_attribute :enrollment_ages_5_17, "Enrollment (Ages 5-17)"
  alias_attribute :free_meal_count_ages_5_17, "Free Meal Count (Ages 5-17)"
  alias_attribute :percent_eligible_free_ages_5_17, "Percent (%) Eligible Free (Ages 5-17)"
  alias_attribute :frpm_count_ages_5_17, "FRPM Count (Ages 5-17)"
  alias_attribute :percent_eligible_frpm_ages_5_17, "Percent (%) Eligible FRPM (Ages 5-17)"
  alias_attribute :calpads_fall_1_certification_status_2013_14, "2013-14 CALPADS Fall 1 Certification Status"

  belongs_to :school, class_name: "School", foreign_key: "cdscode", optional: true
end
