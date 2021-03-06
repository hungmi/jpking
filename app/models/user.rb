class User < ActiveRecord::Base
  enum role: { guest:0, pp: 1, admin: 2 }
  
  validates :name, :email, :phone, uniqueness: true
  validates_format_of :email, :with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, allow_blank: true, message: "Email 格式錯誤，請檢查"
  validates_presence_of :name, :email, :phone, message: "請填寫此欄位"
  has_secure_password

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :points, dependent: :destroy

  def total_paid_sum
    s = 0
    self.orders.where.not("is_paid = ? OR state = ?", false, Order.states["cancel"]).each do |o|
      s += o.total
    end
    return s
  end

  # def deductible_points
  #   self.points.pluck(:value).try(:sum)
  # end

  def deductible_points_for_this_(total)
    max = self.deductible_points
    total > max ? max : total
  end

  def searchable
    "#{self.name}_#{self.email}_#{self.phone}"
  end
end
