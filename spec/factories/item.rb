FactoryGirl.define do
  factory :item do
    description "$30 of awesome for $10"
    association :merchant
  end
end
