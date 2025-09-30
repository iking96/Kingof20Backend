class AllowMultipleEmptyStringEmails < ActiveRecord::Migration[8.0]
  def change
    # Remove the current partial unique index
    remove_index :users, :email if index_exists?(:users, :email)

    # Add a partial unique index that excludes empty strings AND nulls
    add_index :users, :email, unique: true, where: "email IS NOT NULL AND email != ''"
  end
end
