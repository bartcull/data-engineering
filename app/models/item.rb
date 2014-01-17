class Item < ActiveRecord::Base
  belongs_to :merchant
  has_many :purchases
  
  accepts_nested_attributes_for :merchant
end
