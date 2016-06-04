class UploadService
  def self.fog
    Fog::Storage.new({
      provider:              'AWS',                        # required
      aws_access_key_id:     ENV['aws_access_key_id'],                        # required
      aws_secret_access_key: ENV['aws_secret_access_key'],                        # required
      region:                'ap-northeast-1',                  # optional, defaults to 'us-east-1'
      # host:                  's3.amazonaws.com',             # optional, defaults to nil
      # endpoint: "https://jpking-db.s3-website-us-east-1.amazonaws.com"
      # endpoint:              'https://s3.example.com:8080' # optional, defaults to nil
    })
  end
end