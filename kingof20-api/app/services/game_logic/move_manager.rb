# frozen_string_literal: true

module GameLogic
  class MoveManager
    USER_MOVE_QUERY_PARAMS = [:perfect_twenty].freeze
    class << self
      def get_user_moves_with_params(user:, params:)
        moves = user.moves.to_a
        params.each do |key, value|
          moves = reduce_by_param(
            moves: moves,
            user: user,
            key: key,
            _value: value
          )
        end
        games
      end

      private

      def reduce_by_param(moves:, user:, key:, _value:)
        case key
        when "perfect_twenty"
          moves = moves.select { |g| g.initiator == user }
        end
        moves
      end
    end
  end
end
