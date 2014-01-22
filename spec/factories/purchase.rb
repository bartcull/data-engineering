FactoryGirl.define do
  factory :purchase do
    customer "Snake Plissken"
    price 10.0
    item_count 2
    
    association :item
    association :customer
  end
end