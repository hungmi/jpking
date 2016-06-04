require 'rake'
namespace :dev do
  desc "backup db"
  task :backup => [:environment] do |t, args|
    @fog = UploadService.fog
    @dir = @fog.directories.get("jpking-db2")
    @file_index = @dir.files.size
    @file_name = "jpking_dev_#{@file_index + 1}.dump"
    db_name = Rails.application.config.database_configuration[Rails.env]["database"] 
    `pg_dump -Fc --no-acl --no-owner -h localhost -U hungmi #{db_name} > "/Users/hungmi/Documents/jpking_aws/#{@file_name}"`
    #`mv "#{args[:file_name]}" "/Users/hungmi/Documents/jpking_aws/#{args[:file_name]}"`
  end

  desc "upload db"
  task :upload => :environment do
    puts "開始備份..."
    Rake::Task["dev:backup"].invoke
    puts "備份完成，開始上傳..."
    file = @dir.files.create ({
      :key    => @file_name,
      :body   => File.open("/Users/hungmi/Documents/jpking_aws/#{@file_name}"),
      :public => true
    })
    Link.create({
      value: file.public_url,
      fetchable_id: @file_index,
      fetchable_type: "db"
    })
    puts "上傳成功，link: #{Link.last.value}"
  end

  desc "restore db"
  task :restore, [:href] => :environment do |t, args|
    #db_link = Link.where(fetchable_type: "db").order(:id).last.value
    `curl -O #{args[:href]} ~/Documents/jpking_aws`
    `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d jpking_dev #{args[:href]}`
  end

  desc "restore db"
  task :restore_on_production, [:href] => :environment do |t, args|
    db_link = Link.where(fetchable_type: "db").order(:id).last.value
    `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d jpking_production #{db_link}`
  end
end