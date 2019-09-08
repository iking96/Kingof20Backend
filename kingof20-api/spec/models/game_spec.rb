require 'rails_helper'

RSpec.describe Game, type: :model do
  it { should validate_presence_of(:board) }
  it { should validate_presence_of(:initiator_score) }
  it { should validate_presence_of(:initiator_rack) }
  it { should validate_presence_of(:opponent_score) }
  it { should validate_presence_of(:opponent_rack) }
  it { should validate_presence_of(:initiator_id) }
  it { should validate_presence_of(:current_player_id) }
end
