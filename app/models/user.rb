# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :initiated_games, class_name: 'Game', foreign_key: :initiator_id, dependent: :destroy
  has_many :opposing_games, class_name: 'Game', foreign_key: :opponent_id, dependent: :destroy

  has_many :moves, dependent: :destroy
  has_many :game_queue_entries, dependent: :destroy

  has_many :waiting_games, class_name: 'Game', through: :game_queue_entries, source: :game

  validates :encrypted_password, presence: true
  validates :username, presence: true
  validates :username, uniqueness: true
  validates :username, length: { minimum: 2, maximum: 15 }

  validate :username_not_offensive

  def email_required?
    false
  end

  def games
    Game.where('initiator_id = ? or opponent_id = ?', id, id)
  end

  def visible_games
    Game
      .where.not(hidden_from: Game::HIDDEN_FROM_BOTH)
      .where(
        '(initiator_id = ? and hidden_from <> ?) or (opponent_id = ? and hidden_from <> ?)',
        id,
        Game::HIDDEN_FROM_INITIATOR,
        id,
        Game::HIDDEN_FROM_OPPONENT,
      )
  end

  def current_player_games
    games.select { |game| game.current_user == self }
  end

  private

  def username_not_offensive
    return if username.blank?
    errors.add(:username, 'contains inappropriate language') if Obscenity.profane?(username)
  end
end
