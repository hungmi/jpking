class AddTaggingsCountToTags < ActiveRecord::Migration
  def change
    add_column :tags, :taggings_count, :integer, default: 0
    add_column :products, :taggings_count, :integer, default: 0
  end
end
