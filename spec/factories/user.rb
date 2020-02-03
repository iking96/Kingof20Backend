# frozen_string_literal: true

FactoryBot.define do
  sequence :username do |n|
    "person#{n}"
  end

  factory :user do
    email { Faker::Internet.email }
    username
    password { Faker::Internet.password }
  end
end
