module Payable
  extend ActiveSupport::Concern

  included do 
    has_one :payment_info, as: :payable, dependent: :destroy 
  end

  def make_payment!(result)
    if self.deducted_total == result["Amt"]
      case result["PaymentType"]
      when "CREDIT"
        self.paid! && self.credit!
      when "VACC"
        self.atm!
      when "WEBATM"
        self.paid! && self.webatm!  
      end

      self.create_payment_info do |pi|
        pi.merchant_id = result["MerchantID"]
        pi.total = result["Amt"]
        pi.trade_no = result["TradeNo"]
        pi.merchant_order_no = result["MerchantOrderNo"]
        pi.check_code = result["CheckCode"]
        pi.ip = result["IP"]
        pi.payment_type = result["PaymentType"]
        pi.pay_time = result["PayTime"]
        pi.card_6no = result["Card6No"]
        pi.card_4no = result["Card4No"]
        pi.atm_bank_code = result["BankCode"]
        pi.atm_code_no = result["CodeNo"]
        pi.atm_expire_date = result["ExpireDate"]
        pi.atm_expire_time = result["ExpireTime"]
        pi.payer_account_5code = result["PayerAccount5Code"]
        pi.pay_bank_code = result["PayBankCode"]
      end
    end

    if self.payment.present?
      self.order_items.map do |oi|
        oi.update_column(:ordered_price, oi.product.our_price)
        self.paid? ? oi.paid! : oi.wait!
      end
    end
  end

  def make_deduction!(points)
    max_deductible_points = self.total >= points ? points : self.total
    if max_deductible_points >= 0
      self.update(deduction: points)
      self.deducted! if self.reload.deducted_total == 0

      if self.reload.deducted?
        self.order_items.map do |oi|
          oi.update_column(:ordered_price, oi.product.our_price)
          oi.paid!
        end
      end

      return true
    else
      return false        
    end
  end

  def make_payment_2nd_step!(result)
    # binding.pry
    @info = self.payment_info
    if result["Status"] == "SUCCESS"
      if result["TradeStatus"] == "1" && result["Amt"] == @info.total.to_i && result["TradeNo"] == @info.trade_no # 付款成功
        if self.paid!
          self.order_items.map { |oi| oi.paid! }
        end
      end
      return true
    else
      return false
    end
  end

end