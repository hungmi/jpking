namespace :cron do
  desc "Test cron job works or not"
  task :check_cron_job_works => :environment do
    puts "#{Time.now} Cron Job works *( ^ 3 ^ )*y "
  end

  desc "Update houses' and rooms' state"
  task :fetch_rankings => :environment do
    @ee = EtoileServiceCapy.new
    @ee.fetch_rankings
    puts "#{Time.now}, Ranking is fetch successfully."
  end
end