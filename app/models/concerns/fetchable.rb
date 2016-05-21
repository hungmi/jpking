module Fetchable
  extend ActiveSupport::Concern

  included do 
    has_many :links, as: :fetchable, dependent: :destroy 
  end
end