# == Schema Information
#
# Table name: laboratory
#
#  id         :bigint, primary key
#  date       :date, primary key
#  got        :bigint
#  gpt        :bigint
#  ldh        :bigint
#  alp        :bigint
#  tp         :real
#  alb        :real
#  ua         :real
#  un         :bigint
#  cre        :real
#  T-BIL      :real
#  T-CHO      :bigint
#  tg         :bigint
#  cpk        :bigint
#  glu        :bigint
#  wbc        :real
#  rbc        :real
#  hgb        :real
#  hct        :real
#  plt        :bigint
#  pt         :real
#  aptt       :bigint
#  fg         :real
#  pic        :bigint
#  tat        :bigint
#  tat2       :bigint
#  U-PRO      :text
#  igg        :bigint
#  iga        :bigint
#  igm        :bigint
#  crp        :text
#  ra         :text
#  rf         :text
#  c3         :bigint
#  c4         :bigint
#  rnp        :text
#  sm         :text
#  sc170      :text
#  ssa        :text
#  ssb        :text
#  centromea  :text
#  dna        :text
#  DNA-II     :bigint
#
class Laboratory < ApplicationRecord
  self.table_name = "laboratory"
  self.primary_key = ["id", "date"]

  alias_attribute :t_bil, "T-BIL"
  alias_attribute :t_cho, "T-CHO"
  alias_attribute :u_pro, "U-PRO"
  alias_attribute :dna_ii, "DNA-II"

  belongs_to :patient, class_name: "Patient", foreign_key: "id", optional: true
end
