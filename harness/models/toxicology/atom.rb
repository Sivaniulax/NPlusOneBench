# == Schema Information
#
# Table name: atom
#
#  atom_id      :text, not null, primary key
#  molecule_id  :text
#  element      :text
#
class Atom < ApplicationRecord
  self.table_name = "atom"
  self.primary_key = "atom_id"

  belongs_to :molecule, class_name: "Molecule", foreign_key: "molecule_id", optional: true
  has_many :connecteds_as_atom2, class_name: "Connected", foreign_key: "atom_id2"
  has_many :connecteds_as_atom, class_name: "Connected", foreign_key: "atom_id"
end
