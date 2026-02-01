# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Game, type: :model) do
  context 'on creation' do
    let!(:user) { create(:user) }

    context 'when game information is not supplied' do
      it 'fills them in' do
        game = create(
          :game,
          initiator: user,
          board: nil,
          available_tiles: nil,
          initiator_score: nil,
          initiator_rack: nil,
          opponent_score: nil,
          opponent_rack: nil,
          current_player: nil,
        )
        expect(game.board).to(be_a(Array))
        expect(game.initiator_score).to(eq(0))
        expect(game.opponent_score).to(eq(0))
        expect(
          (game.available_tiles +
          game.initiator_rack +
          game.opponent_rack).sort
        ).to(eq(Game.initial_available_tiles.sort))
        expect(game.current_player).to(eq('initiator'))
      end
    end
  end

  it { should validate_presence_of(:initiator) }
  # Complete: using validate_inclusion_of with boolean columns is discouraged

  it 'returns correct tile mappings' do
    expect(Game.available_tiles_string_value(index: 1)).to(eq("1"))
    expect(Game.available_tiles_string_value(index: 13)).to(eq("Over"))
    expect(Game.available_tiles_string_value(index: 14)).to(eq(nil))
  end

  context 'a game' do
    let(:initiating_user) { create(:user) }
    let(:opposing_user) { create(:user) }
    let!(:game) do
      create(
        :game,
        initiator: initiating_user,
        opponent: opposing_user,
      )
    end

    it 'can return current user' do
      expect(game.current_user).to(eq(initiating_user))
    end

    it 'does not allow unrecognized current_player values' do
      expect { game.current_player = 'some_string' }.to(raise_error(ArgumentError))
    end

    it 'does not allow unrecognized stage value' do
      expect { game.stage = 'some_string' }.to(raise_error(ArgumentError))
    end

    it 'does not allow unrecognized hidden_from value' do
      expect do
        game.hidden_from = 4
        game.save!
      end.to(raise_error(ActiveRecord::RecordInvalid))
    end

    context 'when a user forfits' do
      subject do
        game.forfit_user(user: forfiting_user)
        game.save!
        game.reload
      end

      context 'the initating user' do
        let(:forfiting_user) { initiating_user }

        it 'move the game to the correct stage' do
          subject
          expect(game.stage).to(eq('initiator_forfit'))
        end
      end

      context 'the opposing user' do
        let(:forfiting_user) { opposing_user }

        it 'move the game to the correct stage' do
          subject
          expect(game.stage).to(eq('opponent_forfit'))
        end
      end
    end

    it 'does not allow initiator == opponent' do
      expect do
        game.opponent = initiating_user
        game.save!
      end.to(raise_error(ActiveRecord::RecordInvalid))
    end

    it 'can determine if swapping is allowed' do
      expect(game.allow_swap?).to(eq(true))
    end
  end

  context 'when a user is involved in a game' do
    let(:initiating_user) { create(:user) }
    let(:opposing_user) { create(:user) }
    let!(:game) do
      create(:game, initiator: initiating_user)
    end
    let(:user_games) { initiating_user.games }

    it 'is possible to find users involved in game' do
      expect(game.initiator).to(eq(initiating_user))
    end
  end

  context 'when a game has moves' do
    let(:initiating_user) { create(:user) }
    let(:game) do
      create(:game, initiator: initiating_user)
    end
    let!(:move1) { create(:move, game: game, user: initiating_user, move_type: 'tile_placement') }
    let!(:move2) { create(:move, game: game, user: initiating_user, move_type: 'tile_placement') }

    it 'is possible find moves from game' do
      expect(game.moves.size).to(eq(2))
    end
  end

  context 'AI games' do
    let(:user) { create(:user) }

    context 'when ai_difficulty is set' do
      let(:game) { create(:game, initiator: user, opponent: nil, ai_difficulty: 'easy') }

      it 'is recognized as a computer game' do
        expect(game.vs_computer?).to(eq(true))
      end

      it 'allows nil opponent' do
        expect(game).to(be_valid)
        expect(game.opponent).to(be_nil)
      end

      it 'does not require opponent validation' do
        expect(game.errors[:initiator]).to(be_empty)
      end

      context 'with easy difficulty' do
        it 'returns correct ai_difficulty value' do
          expect(game.ai_difficulty).to(eq('easy'))
          expect(game.ai_difficulty_easy?).to(eq(true))
          expect(game.ai_difficulty_hard?).to(eq(false))
        end
      end

      context 'with hard difficulty' do
        let(:game) { create(:game, initiator: user, opponent: nil, ai_difficulty: 'hard') }

        it 'returns correct ai_difficulty value' do
          expect(game.ai_difficulty).to(eq('hard'))
          expect(game.ai_difficulty_easy?).to(eq(false))
          expect(game.ai_difficulty_hard?).to(eq(true))
        end
      end
    end

    context 'when ai_difficulty is not set' do
      let(:game) { create(:game, initiator: user, opponent: create(:user)) }

      it 'is not recognized as a computer game' do
        expect(game.vs_computer?).to(eq(false))
      end
    end

    context 'current_turn_is_ai?' do
      let(:game) { create(:game, initiator: user, opponent: nil, ai_difficulty: 'easy') }

      it 'returns false when current_player is initiator' do
        game.current_player = 'initiator'
        expect(game.current_turn_is_ai?).to(eq(false))
      end

      it 'returns true when current_player is opponent in AI game' do
        game.current_player = 'opponent'
        expect(game.current_turn_is_ai?).to(eq(true))
      end

      context 'in a human vs human game' do
        let(:game) { create(:game, initiator: user, opponent: create(:user)) }

        it 'returns false even when current_player is opponent' do
          game.current_player = 'opponent'
          expect(game.current_turn_is_ai?).to(eq(false))
        end
      end
    end

    context 'computer_opponent_data' do
      let(:game) { create(:game, initiator: user, opponent: nil, ai_difficulty: 'easy') }

      it 'returns computer opponent info for easy AI' do
        data = game.computer_opponent_data
        expect(data['id']).to(eq(0))
        expect(data['username']).to(eq('Computer (Easy)'))
      end

      context 'with hard difficulty' do
        let(:game) { create(:game, initiator: user, opponent: nil, ai_difficulty: 'hard') }

        it 'returns computer opponent info for hard AI' do
          data = game.computer_opponent_data
          expect(data['username']).to(eq('Computer (Hard)'))
        end
      end

      context 'for human vs human game' do
        let(:game) { create(:game, initiator: user, opponent: create(:user)) }

        it 'returns nil' do
          expect(game.computer_opponent_data).to(be_nil)
        end
      end
    end
  end
end
