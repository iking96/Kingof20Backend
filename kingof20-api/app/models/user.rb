class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :initiated_games, class_name: 'Game', foreign_key: :initiator_id, dependent: :destroy
  has_many :opposing_games, class_name: 'Game', foreign_key: :opponent_id, dependent: :destroy
  has_many :current_player_games, class_name: 'Game', foreign_key: :current_player_id

  has_many :moves, dependent: :destroy

  has_many :game_queue_entries
  has_many :waiting_games, class_name: 'Game', through: :game_queue_entries, source: :game 

  validates :email, presence: true
  validates :encrypted_password, presence: true
  validates :encrypted_password, uniqueness: true
  validates :username, presence: true
  validates :username, uniqueness: true

  def games
    Game.where('initiator_id = ? or opponent_id = ?', id, id)
  end
end
