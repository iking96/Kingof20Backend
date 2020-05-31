# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PlayLogic::ScoreHelpers) do
  describe 'score_board_slice' do
    subject { described_class.score_board_slice(board_slice: board_slice, start: start) }

    let(:board_slice) { [0, 0, 5, 11, 4, 0, 0, 0, 0, 0, 0, 0] }
    let(:start) { 2 }

    it 'returns the correct result' do
      expect(subject.success?).to(eq(true))
      expect(subject.value).to(eq(0))
    end

    context 'when there is a leading operation' do
      let(:board_slice) { [0, 10, 5, 11, 4, 0, 0, 0, 0, 0, 0, 0] }

      it 'returns the correct result' do
        expect(subject.success?).to(eq(true))
        expect(subject.value).to(eq(0))
      end
    end

    context 'when there is a trailing operation' do
      let(:board_slice) { [0, 10, 5, 11, 4, 12, 0, 0, 0, 0, 0, 0] }

      it 'returns the correct result' do
        expect(subject.success?).to(eq(true))
        expect(subject.value).to(eq(0))
      end
    end

    context 'works for subtraction' do
      let(:board_slice) { [0, 0, 5, 11, 4, 12, 3, 0, 0, 0, 0, 0] }

      it 'returns the correct result' do
        expect(subject.success?).to(eq(true))
        expect(subject.value).to(eq(3))
      end
    end

    context 'works for addition' do
      let(:board_slice) { [0, 0, 5, 11, 4, 10, 3, 0, 0, 0, 0, 0] }

      it 'returns the correct result' do
        expect(subject.success?).to(eq(true))
        expect(subject.value).to(eq(3))
      end
    end

    context 'works for division' do
      let(:board_slice) { [0, 0, 9, 13, 3, 11, 7, 0, 0, 0, 0, 0] }

      it 'returns the correct result' do
        expect(subject.success?).to(eq(true))
        expect(subject.value).to(eq(1))
      end
    end

    context 'when the input is invalid' do
      context 'there is no expression' do
        let(:board_slice) { [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(false))
          expect(subject.errors).to(eq([:expression_not_found]))
        end
      end

      context 'start is negatie' do
        let(:start) { -1 }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(false))
          expect(subject.errors).to(eq([:expression_not_found]))
        end
      end

      context 'start is to large' do
        let(:start) { 20 }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(false))
          expect(subject.errors).to(eq([:expression_not_found]))
        end
      end

      context 'start is not one an expression' do
        let(:start) { 0 }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(false))
          expect(subject.errors).to(eq([:expression_not_found]))
        end
      end

      context 'there is no expression after the start' do
        let(:board_slice) { [5, 10, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0] }
        let(:start) { 3 }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(false))
          expect(subject.errors).to(eq([:expression_not_found]))
        end
      end

      context 'the expression goes negative' do
        let(:board_slice) { [0, 5, 11, 4, 12, 9, 12, 9, 12, 9, 10, 9] }
        let(:start) { 1 }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(false))
          expect(subject.errors).to(eq([:expression_causes_negative]))
        end
      end

      context 'the expression causes fraction' do
        let(:board_slice) { [0, 5, 11, 4, 13, 7, 11, 7, 0, 0, 0, 0] }
        let(:start) { 1 }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(false))
          expect(subject.errors).to(eq([:expression_causes_fraction]))
        end
      end
    end

    context 'when the slice is on an edge' do
      context 'the left edge' do
        let(:board_slice) { [5, 10, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0] }
        let(:start) { 0 }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(true))
          expect(subject.value).to(eq(11))
        end
      end

      context 'the left edge, does not start at zero' do
        let(:board_slice) { [5, 10, 4, 10, 4, 0, 0, 0, 0, 0, 0, 0] }
        let(:start) { 3 }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(true))
          expect(subject.value).to(eq(7))
        end
      end

      context 'the right edge' do
        let(:board_slice) { [0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 10, 4] }
        let(:start) { 9 }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(true))
          expect(subject.value).to(eq(11))
        end
      end
    end

    context 'when their are multiple expressions in the slice' do
      context 'the first is set to be evaluated' do
        let(:board_slice) { [0, 0, 5, 11, 4, 0, 9, 10, 9, 0, 0, 0] }
        let(:start) { 2 }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(true))
          expect(subject.value).to(eq(0))
        end
      end

      context 'the second is set to be evaluated' do
        let(:board_slice) { [0, 0, 5, 11, 4, 0, 9, 10, 9, 0, 0, 0] }
        let(:start) { 6 }

        it 'returns the correct result' do
          expect(subject.success?).to(eq(true))
          expect(subject.value).to(eq(2))
        end
      end
    end
  end
end
