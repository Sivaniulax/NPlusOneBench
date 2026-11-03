# == Schema Information
#
# Table name: bond
#
#  bond_id      :text, not null, primary key
#  molecule_id  :text
#  bond_type    :text
#
class Bond < ApplicationRecord
  self.table_name = "bond"
  self.primary_key = "bond_id"

  belongs_to :molecule, class_name: "Molecule", foreign_key: "molecule_id", optional: true
  has_many :connecteds, class_name: "Connected", foreign_key: "bond_id"
end
