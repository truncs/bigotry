class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :name
      t.text :content
      t.text :headline
      t.string :url
      t.integer :event_id
      t.integer :source_id

      t.timestamps
    end
  end
end
