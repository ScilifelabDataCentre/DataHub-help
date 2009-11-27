class CreateAssetAuthors < ActiveRecord::Migration
  def self.up
    create_table :asset_authors do |t|
      t.integer :asset_id
      t.integer :author_id
      t.timestamps
    end
  end

  def self.down
    drop_table :asset_authors
  end
end
