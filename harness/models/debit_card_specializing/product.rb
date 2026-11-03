# == Schema Information
#
# Table name: products
#
#  productid    :bigint, not null, primary key
#  description  :text
#
class Product < ApplicationRecord
  self.table_name = "products"
  self.primary_key = "productid"
end
