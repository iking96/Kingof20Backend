# frozen_string_literal: true

module UserLogic
  class StatsCalculator
    COMPLETE_STAGES = %w[complete initiator_forfit opponent_forfit].freeze

    def initialize(user)
      @user = user
    end

    def calculate
      completed_games = @user.games.where(stage: COMPLETE_STAGES)

      wins = 0
      losses = 0
      total_score = 0

      completed_games.each do |game|
        user_score = score_for_user(game)
        total_score += user_score

        winner = game.determine_winner
        if winner == role_in_game(game)
          wins += 1
        elsif winner == 'tie'
          # Ties don't count as wins or losses
        else
          losses += 1
        end
      end

      games_played = wins + losses
      {
        games_played: games_played,
        wins: wins,
        losses: losses,
        win_rate: games_played.positive? ? ((wins.to_f / games_played) * 100).round : 0,
        average_score: games_played.positive? ? (total_score.to_f / games_played).round : 0,
      }
    end

    private

    def role_in_game(game)
      game.initiator_id == @user.id ? 'initiator' : 'opponent'
    end

    def score_for_user(game)
      if game.initiator_id == @user.id
        game.initiator_score
      else
        game.opponent_score
      end
    end
  end
end
