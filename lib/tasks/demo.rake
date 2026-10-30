namespace :demo do
  desc "Delete demo sessions older than their fixed seven-day lifetime"
  task cleanup: :environment do
    count = 0
    DemoSession.expired.find_each do |demo|
      demo.with_lock do
        demo.destroy!
        count += 1
      end
    end
    puts "Deleted #{count} expired demo sessions and their tasks."
  end
end
