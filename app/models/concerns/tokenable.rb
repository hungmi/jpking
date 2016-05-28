module Tokenable
  extend ActiveSupport::Concern

  included do 
    before_create :generate_token
    validates :token, uniqueness: true
  end

  def generate_token
    self.token = SecureRandom.uuid
  end
end