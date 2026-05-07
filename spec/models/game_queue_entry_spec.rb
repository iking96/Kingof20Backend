# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(GameQueueEntry, type: :model) do
  subject { build(:game_queue_entry) }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:game) }
  it { should validate_uniqueness_of(:user_id) }
end
