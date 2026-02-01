class AddAiDifficultyToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :ai_difficulty, :string
  end
end
