class Link < ActiveRecord::Base
  enum state: { alive: 0, dead: 1 }

  belongs_to :fetchable, polymorphic: true, touch: true

  validates :value, uniqueness: true

  def extract_params
    params = {}
    self.value.match(/[^\?]*$/)[0].strip.split("&").each do |param_str|
      result = param_str.split("=");
      params[result[0].to_sym] = result[1];
    end
    return params
  end

  def up_to_date?
    if dead?
      true # 這樣才不會再抓
    else
      fetch_time.present? && (self.fetch_time > ( Time.now - 1.day ))
    end
  end
end
