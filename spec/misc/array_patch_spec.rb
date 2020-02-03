# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Array) do
  describe 'subtract_once' do
    let(:array1) { [1, 1, 2, 2, 3, 3] }
    let(:array2) { [1, 2, 3] }

    it 'removes elements as their appear in array2' do
      expect(array1.subtract_once(array2)).to(eq([1, 2, 3]))
    end
  end
end
