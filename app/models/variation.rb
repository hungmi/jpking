class Variation < ActiveRecord::Base
  belongs_to :product, counter_cache: true
end
