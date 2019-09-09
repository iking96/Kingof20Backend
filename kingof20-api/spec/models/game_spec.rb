require 'rails_helper'

RSpec.describe Game, type: :model do
  it { should validate_presence_of(:board) }
  it { should validate_presence_of(:initiator_score) }
  it { should validate_presence_of(:initiator_rack) }
  it { should validate_presence_of(:opponent_score) }
  it { should validate_presence_of(:opponent_rack) }
  it { should validate_presence_of(:initiator_id) }
  it { should validate_presence_of(:current_player_id) }
  # Complete: using validate_inclusion_of with boolean columns is discuraged
  it { should validate_presence_of(:available_tiles) }

  it "returns correct tile mappings" do
    expect(Game.available_tiles_string_value(index: 1)).to eq("1")
    expect(Game.available_tiles_string_value(index: 13)).to eq("Over")
    expect(Game.available_tiles_string_value(index: 14)).to eq(nil)
  end
end
