require 'rails_helper'

RSpec.describe Move, type: :model do
  it { should validate_presence_of(:row_num) }
  it { should validate_presence_of(:col_num) }
  it { should validate_presence_of(:move_number) }
  it { should validate_presence_of(:tile_value) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:game) }
end
