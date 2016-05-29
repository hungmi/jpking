class AddColumnsAboutAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :source_url, :string
    add_column :products, :attachments_count, :integer, default: 0
  end
end
