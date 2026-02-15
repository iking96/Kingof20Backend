# frozen_string_literal: true

module UserLogic
  class StatsCalculator
    COMPLETE_STAGES = %w[complete initiator_forfit opponent_forfit].freeze

    def initialize(user)
      @user = user
    end

    def calculate
      completed_games = @user.games.where(stage: COMPLETE_STAGES)
      fully_completed_games = @user.games.where(stage: 'complete')

      wins = 0
      losses = 0

      completed_games.each do |game|
        winner = game.determine_winner
        if winner == role_in_game(game)
          wins += 1
        elsif winner == 'tie'
          # Ties don't count as wins or losses
        else
          losses += 1
        end
      end

      # Calculate average score only from fully completed games (no forfeits)
      total_score_from_completed_games = 0
      fully_completed_games.each do |game|
        total_score_from_completed_games += score_for_user(game)
      end
      fully_completed_count = fully_completed_games.count

      games_played = wins + losses

      {
        games_played: games_played,
        wins: wins,
        losses: losses,
        win_rate: games_played.positive? ? ((wins.to_f / games_played) * 100).round : 0,
        average_score: fully_completed_count.positive? ? (total_score_from_completed_games.to_f / fully_completed_count).round : 0,
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
