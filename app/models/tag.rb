class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  def self.most_used(num)
    num ||= 20
    Tag.order(taggings_count: :desc).limit(num)
  end
end
