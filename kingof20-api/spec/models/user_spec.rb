require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:encrypted_password) }
  it { should validate_uniqueness_of(:username) }
  it { should validate_uniqueness_of(:encrypted_password) }

  context 'when the user is involved in a game' do
    let(:initiating_user) { create(:user) }
    let(:opposing_user) { create(:user) }
    let!(:game) { create(:game,
      initiator_id: initiating_user.id,
      opponent_id: opposing_user.id,
      current_player_id: initiating_user.id,
      initiator_rack: [7,6,5,4,3,2,1],
      )
    }
    let(:user_games) { initiating_user.games }

    it 'works' do
      expect(user_games.size).to eq(1)
      expect(user_games.first.initiator_rack).to eq(
        [7,6,5,4,3,2,1],
      )
    end
  end
end
