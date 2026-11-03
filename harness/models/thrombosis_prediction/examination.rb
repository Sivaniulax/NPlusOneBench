# == Schema Information
#
# Table name: examination
#
#  id                :bigint
#  Examination Date  :date
#  aCL IgG           :real
#  aCL IgM           :real
#  ana               :bigint
#  ANA Pattern       :text
#  aCL IgA           :bigint
#  diagnosis         :text
#  kct               :text
#  rvvt              :text
#  lac               :text
#  symptoms          :text
#  thrombosis        :bigint
#
class Examination < ApplicationRecord
  self.table_name = "examination"
  # no primary key in the source data

  alias_attribute :examination_date, "Examination Date"
  alias_attribute :a_cl_ig_g, "aCL IgG"
  alias_attribute :a_cl_ig_m, "aCL IgM"
  alias_attribute :ana_pattern, "ANA Pattern"
  alias_attribute :a_cl_ig_a, "aCL IgA"

  belongs_to :patient, class_name: "Patient", foreign_key: "id", optional: true
end
