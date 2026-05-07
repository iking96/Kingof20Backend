# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PlayLogic::GameQueueEntryLogic::GameQueueEntryManager) do
  describe '.enqueue_game' do
    let(:user) { create(:user) }
    let(:game) { create(:game, initiator: user) }

    context 'when user has no existing queue entry' do
      it 'creates a queue entry' do
        expect do
          described_class.enqueue_game(game: game)
        end.to(change(GameQueueEntry, :count).by(1))
      end
    end

    context 'when user already has a queue entry' do
      before { described_class.enqueue_game(game: game) }

      it 'raises Error::Game::ProcessingError with :game_already_queued code' do
        second_game = create(:game, initiator: user)
        expect do
          described_class.enqueue_game(game: second_game)
        end.to(raise_error(Error::Game::ProcessingError)) do |error|
          expect(error.error_code).to(eq(:game_already_queued))
          expect(error.message).to(eq(Error::Game::ProcessingError::PROCESSING_ERRORS[:game_already_queued]))
        end
      end
    end
  end
end
