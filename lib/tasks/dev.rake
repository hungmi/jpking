namespace :dev do
  desc "backup db"
  task :backup => :environment do
    db_name = Rails.application.config.database_configuration[Rails.env]["database"]
    db_file = "jpking_dev_.dump"
    `PGPASSWORD=mypassword pg_dump -Fc --no-acl --no-owner -h localhost -U hungmi #{db_name} > #{db_file}`
  end

  desc "restore db"
  task :add, [:href] do |t, args|
    `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d jpking_dev #{args[:href]}`
  end
end