class Tagging < ActiveRecord::Base
  belongs_to :tag, counter_cache: true
  belongs_to :taggable, polymorphic: true, counter_cache: true
end
