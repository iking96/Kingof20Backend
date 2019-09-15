class GameQueueEntry < ApplicationRecord
  belongs_to :game
  belongs_to :user

  validates :user, presence: true
  validates :game, presence: true
end
