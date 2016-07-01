class User < ActiveRecord::Base
  enum role: { guest:0, pp: 1, admin: 2 }
  
  validates :name, :email, :phone, uniqueness: true
  validates_format_of :email, :with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, allow_blank: true, message: "Email 格式錯誤，請檢查"
  validates_presence_of :name, :email, :phone, message: "請填寫此欄位"
  has_secure_password

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
end
