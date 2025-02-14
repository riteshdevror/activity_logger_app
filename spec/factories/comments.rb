FactoryBot.define do
  factory :comment do
    content { "Test comment" }
    association :project
    association :user
  end
end
