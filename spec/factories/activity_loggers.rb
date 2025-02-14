FactoryBot.define do
  factory :activity_logger do
    trackable_type { "MyString" }
    trackable_id { "" }
    action { "MyString" }
    field_name { "MyString" }
    previous_value { "MyText" }
    new_value { "MyText" }
  end
end
