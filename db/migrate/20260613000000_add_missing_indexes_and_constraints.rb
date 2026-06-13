class AddMissingIndexesAndConstraints < ActiveRecord::Migration[8.1]
  def up
    User.where(api_token: nil).find_each do |user|
      user.update!(api_token: Digest::SHA256.hexdigest(SecureRandom.hex(32)))
    end

    change_column_null :users, :api_token, false

    add_index :tasks, :status
    add_index :tasks, :priority
    add_index :tasks, [ :project_id, :created_at ]
  end

  def down
    change_column_null :users, :api_token, true

    remove_index :tasks, column: :status
    remove_index :tasks, column: :priority
    remove_index :tasks, column: [ :project_id, :created_at ]
  end
end
