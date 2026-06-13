class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, default: "backlog"
      t.integer :priority, default: 0
      t.date :due_date
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
