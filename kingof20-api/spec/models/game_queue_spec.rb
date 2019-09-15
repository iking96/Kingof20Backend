require 'rails_helper'

RSpec.describe GameQueue, type: :model do
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:game) }
end
