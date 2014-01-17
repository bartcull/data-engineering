class Purchase < ActiveRecord::Base
  belongs_to :item
  belongs_to :customer
  has_one :merchant, through: :item
  
  accepts_nested_attributes_for :item, :customer, :merchant
end
