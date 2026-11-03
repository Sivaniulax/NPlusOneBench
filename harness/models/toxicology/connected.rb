# == Schema Information
#
# Table name: connected
#
#  atom_id   :text, not null, primary key
#  atom_id2  :text, not null, primary key
#  bond_id   :text
#
class Connected < ApplicationRecord
  self.table_name = "connected"
  self.primary_key = ["atom_id", "atom_id2"]

  belongs_to :bond, class_name: "Bond", foreign_key: "bond_id", optional: true
  belongs_to :atom2, class_name: "Atom", foreign_key: "atom_id2", optional: true
  belongs_to :atom, class_name: "Atom", foreign_key: "atom_id", optional: true
end
