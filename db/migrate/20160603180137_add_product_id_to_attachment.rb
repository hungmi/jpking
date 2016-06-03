class AddProductIdToAttachment < ActiveRecord::Migration
  def change
    add_reference :attachments, :product, index: true, foreign_key: true
  end
end
