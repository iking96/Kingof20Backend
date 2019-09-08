class AddUserReferencesToGames < ActiveRecord::Migration[5.2]
  def change
    change_table :games do |t|
      t.references :initiator, index: true, foreign_key: {to_table: :users}
      t.references :opponent, index: true, foreign_key: {to_table: :users}
      t.references :current_player, index: true, foreign_key: {to_table: :users}
    end
  end
end
