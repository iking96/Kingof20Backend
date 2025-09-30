class AllowNullEmailsForUsers < ActiveRecord::Migration[8.0]
  def change
    # First, allow NULL values in the email column
    change_column_null :users, :email, true

    # Update existing empty emails to NULL
    execute "UPDATE users SET email = NULL WHERE email = ''"

    # Remove the unique index on email
    remove_index :users, :email if index_exists?(:users, :email)

    # Add a partial unique index that only applies to non-NULL emails
    add_index :users, :email, unique: true, where: "email IS NOT NULL"
  end
end
