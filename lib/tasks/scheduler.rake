namespace :scheduler do
  desc "run scrapers once per week"
  task :scrape do
    if Time.now.wday == 2 then
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['scrape:govt'].invoke 
      Rake::Task['scrape:wiki'].invoke 
      Rake::Task['scrape:muni'].invoke 
      Rake::Task['scrape:db'].invoke
      Rake::Task['scrape:csv'].invoke
    end
  end
end
