class Attachment < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  include Tokenable
  belongs_to :imageable, polymorphic: true, counter_cache: true
  validates :source_url, uniqueness: true
end
