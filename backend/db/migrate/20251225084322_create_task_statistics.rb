class CreateTaskStatistics < ActiveRecord::Migration[8.1]
  def change
    create_table :task_statistics do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.integer :total_tasks
      t.integer :completed_tasks
      t.float :completion_rate

      t.timestamps
    end
  end
end
