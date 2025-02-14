class CreateActivityLoggers < ActiveRecord::Migration[7.1]
  def change
    create_table :activity_loggers do |t|
      t.string :trackable_type
      t.bigint :trackable_id
      t.string :action
      t.string :field_name
      t.text :previous_value
      t.text :new_value

      t.timestamps
    end
  end
end
