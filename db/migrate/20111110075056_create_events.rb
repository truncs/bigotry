class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.string :search_string
      t.datetime :from_date
      t.datetime :to_date

      t.timestamps
    end
  end
end
