# frozen_string_literal: true

FactoryBot.define do
  factory :game_queue_entry do
    user { create(:user) }
    game { create(:game, initiator: user) }
  end
end
