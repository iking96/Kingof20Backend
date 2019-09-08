class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.integer :board, :array => true
      t.integer :initiator_score, :default => 0
      t.integer :initiator_rack, :array => true
      t.integer :opponent_score, :default => 0
      t.integer :opponent_rack, :array => true

      t.timestamps
    end
  end
end
