FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    username { Faker::Lorem.word }
    password { Faker::Internet.password }
  end
end
