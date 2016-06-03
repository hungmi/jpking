class Attachment < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  include Tokenable

  belongs_to :imageable, polymorphic: true, counter_cache: true
  belongs_to :product, -> { where(attachments: {imageable_type: 'Product'}) }, foreign_key: 'imageable_id'
  
  validates :source_url, uniqueness: true
end
