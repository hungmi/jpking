require 'rake'
namespace :dev do
  desc "backup db"
  task :backup, [:tablename] => [:environment] do |t, args|
    @fog = UploadService.fog
    @dir = @fog.directories.get("jpking-db2")
    @file_index = @dir.files.size
    @local_dir = "/Users/hungmi/Documents/jpking_aws"
    db_name = Rails.application.config.database_configuration[Rails.env]["database"]
    case args[:tablename]
    when nil
      puts "開始備份完整資料庫..."
      @file_name = "jpking_dev_#{@file_index + 1}.dump"
      `pg_dump -Fc --no-acl --no-owner -h localhost -U hungmi #{db_name} > "#{@local_dir}/#{@file_name}"`
      puts "備份完成，開始上傳..."
      Rake::Task["dev:upload"].invoke()
    else
      puts "開始備份#{args[:tablename]}"
      @file_name = "#{args[:tablename]}_#{Time.now.strftime("%m%d%H%M")}.dump"
      `pg_dump -Fc --data-only -d jpking_dev --table=#{args[:tablename]} > #{@local_dir}/#{@file_name}`
      puts "備份完成，開始上傳..."
      Rake::Task["dev:upload"].invoke(args[:tablename])
    end
    #`mv "#{args[:file_name]}" "/Users/hungmi/Documents/jpking_aws/#{args[:file_name]}"`
  end

  desc "upload db"
  task :upload, [:backup_type] => :environment do |t, args|
    # binding.pry
    file = @dir.files.create ({
      :key    => @file_name,
      :body   => File.open("#{@local_dir}/#{@file_name}"),
      :public => true
    })
    Link.create({
      value: file.public_url,
      fetchable_id: @file_index,
      fetchable_type: args[:backup_type]
    })
    puts "上傳成功，link: '#{Link.last.value}'"
  end

  desc "restore db"
  task :restore, [:db_name] => :environment do |t, args|
    #db_link = Link.where(fetchable_type: "db").order(:id).last.value
    #`curl -O #{args[:db_name]} ~/Documents/jpking_aws`
    rails_db_name = Rails.application.config.database_configuration[Rails.env]["database"] 
    `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U hungmi -d #{rails_db_name} #{args[:db_name]}`
  end

  desc "restore table on production"
  task :restore_on_production, [:db_link, :type] => :environment do |t, args|
    #db_link = Link.where(fetchable_type: "db").order(:id).last.value
    rails_db_name = Rails.application.config.database_configuration[Rails.env]["database"] 
    file_name = args[:db_link][/[^\/]*$/]
    @server_dir = "/home/deploy/db_backups"
    `wget -O #{@server_dir} #{db_link}`
    case type
    when "full"
      `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U jpking -d #{rails_db_name} #{@server_dir}/#{file_name}`
    when "table"
      `psql #{rails_db_name} < #{@server_dir}/#{file_name}`
    end
  end
end