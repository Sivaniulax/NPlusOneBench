# == Schema Information
#
# Table name: molecule
#
#  molecule_id  :text, not null, primary key
#  label        :text
#
class Molecule < ApplicationRecord
  self.table_name = "molecule"
  self.primary_key = "molecule_id"

  has_many :atoms, class_name: "Atom", foreign_key: "molecule_id"
  has_many :bonds, class_name: "Bond", foreign_key: "molecule_id"
end
