class Link < ActiveRecord::Base
  belongs_to :fetchable, polymorphic: true

  validates :value, uniqueness: true

  def extract_params
    params = {}
    self.value.match(/[^\?]*$/)[0].strip.split("&").each do |param_str|
      result = param_str.split("=");
      params[result[0].to_sym] = result[1];
    end
    return params
  end
end
