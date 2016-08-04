class Pay2goService

  def initialize(order)
    @order = order
    @timestamp = order.created_at.to_i
    @merchant_order_no = if order.payment_info.present?
      @trade_no = order.payment_info.trade_no
      order.payment_info.merchant_order_no
    else
      "#{order.id}s#{Time.now.strftime("%Y%m%d%H%M%S")}"
    end
    @total_price = order.deducted_total
  end

  def check_value
    d = Digest::SHA256.hexdigest(url_params).upcase
  end

  def url_params
    "HashKey=#{Pay2go.hash_key}&Amt=#{@total_price}&MerchantID=#{Pay2go.merchant_id}&MerchantOrderNo=#{@merchant_order_no}&TimeStamp=#{@timestamp}&Version=1.2&HashIV=#{Pay2go.hash_iv}"
  end

  def check_value_for_check_pay
    d = Digest::SHA256.hexdigest(url_params_for_check_pay).upcase
  end

  def url_params_for_check_pay
    "IV=#{Pay2go.hash_iv}&Amt=#{@total_price}&MerchantID=#{Pay2go.merchant_id}&MerchantOrderNo=#{@merchant_order_no}&Key=#{Pay2go.hash_key}"
  end

  def check_pay_url
    if Rails.env.production?
      "https://api.pay2go.com/API/QueryTradeInfo"
    elsif Rails.env.development?
      "https://capi.pay2go.com/API/QueryTradeInfo"
    else
      nil
    end
  end

  def check_pay!
    url_params = "MerchantID=#{Pay2go.merchant_id}&RespondType=JSON&Version=1.2&MerchantOrderNo=#{@merchant_order_no}&TimeStamp=#{@timestamp}&Amt=#{@total_price}&CheckValue=#{self.check_value_for_check_pay}".split("&").join(" -d ")
    return `curl -X POST -d #{url_params} #{self.check_pay_url}`
  end

  def check_code_for_check_pay # 備而不用
    "HashIV=#{Pay2go.hash_iv}&Amt=#{@total_price}&MerchantID=#{Pay2go.merchant_id}&MerchantOrderNo=#{@merchant_order_no}&TradeNo=#{@trade_no}&HashKey=#{Pay2go.hash_key}"
  end

end