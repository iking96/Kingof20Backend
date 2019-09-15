class RenameGameQueueToGameQueueEntry < ActiveRecord::Migration[5.2]
  def change
    rename_table :game_queues, :game_queue_entries
  end
end
