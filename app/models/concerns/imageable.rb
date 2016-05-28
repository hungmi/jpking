module Imageable
  extend ActiveSupport::Concern

  included do 
    has_many :attachments, as: :imageable, dependent: :destroy
    accepts_nested_attributes_for :attachments, allow_destroy: true
    #validates :imageable_id, presence: true
  end
end