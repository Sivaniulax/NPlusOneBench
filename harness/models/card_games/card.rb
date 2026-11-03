# == Schema Information
#
# Table name: cards
#
#  id                       :bigint, not null, primary key
#  artist                   :text
#  asciiname                :text
#  availability             :text
#  bordercolor              :text
#  cardkingdomfoilid        :text
#  cardkingdomid            :text
#  coloridentity            :text
#  colorindicator           :text
#  colors                   :text
#  convertedmanacost        :real
#  dueldeck                 :text
#  edhrecrank               :bigint
#  faceconvertedmanacost    :real
#  facename                 :text
#  flavorname               :text
#  flavortext               :text
#  frameeffects             :text
#  frameversion             :text
#  hand                     :text
#  hasalternativedecklimit  :bigint
#  hascontentwarning        :bigint
#  hasfoil                  :bigint
#  hasnonfoil               :bigint
#  isalternative            :bigint
#  isfullart                :bigint
#  isonlineonly             :bigint
#  isoversized              :bigint
#  ispromo                  :bigint
#  isreprint                :bigint
#  isreserved               :bigint
#  isstarter                :bigint
#  isstoryspotlight         :bigint
#  istextless               :bigint
#  istimeshifted            :bigint
#  keywords                 :text
#  layout                   :text
#  leadershipskills         :text
#  life                     :text
#  loyalty                  :text
#  manacost                 :text
#  mcmid                    :text
#  mcmmetaid                :text
#  mtgarenaid               :text
#  mtgjsonv4id              :text
#  mtgofoilid               :text
#  mtgoid                   :text
#  multiverseid             :text
#  name                     :text
#  number                   :text
#  originalreleasedate      :text
#  originaltext             :text
#  originaltype             :text
#  otherfaceids             :text
#  power                    :text
#  printings                :text
#  promotypes               :text
#  purchaseurls             :text
#  rarity                   :text
#  scryfallid               :text
#  scryfallillustrationid   :text
#  scryfalloracleid         :text
#  setcode                  :text
#  side                     :text
#  subtypes                 :text
#  supertypes               :text
#  tcgplayerproductid       :text
#  text                     :text
#  toughness                :text
#  type                     :text
#  types                    :text
#  uuid                     :text
#  variations               :text
#  watermark                :text
#
class Card < ApplicationRecord
  self.table_name = "cards"

  has_many :foreign_data, class_name: "ForeignData", foreign_key: "uuid", primary_key: "uuid"
  has_many :legalities, class_name: "Legality", foreign_key: "uuid", primary_key: "uuid"
  has_many :rulings, class_name: "Ruling", foreign_key: "uuid", primary_key: "uuid"
end
