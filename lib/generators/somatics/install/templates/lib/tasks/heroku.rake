namespace :heroku do
  desc "Configure Heroku"
  task :setup, :name do |t, args|
    app_name = args.name
    system "git init"
    system "heroku info || heroku create #{app_name}"
    system "git add ."
    system "git commit -a -m 'Initial Commit'"
    # system "heroku addons:add cron:daily"
    system "heroku addons:add deployhooks:email \
        recipient=heroku@inspiresynergy.com \
        subject='[#{app_name}] Deployed' \
        body='{{user}} deployed #{app_name} successfully'"
    system "heroku addons:add piggyback_ssl"
    system "heroku addons:add newrelic:bronze"
  end
  
  desc "Deploy to Heroku"
  task :deploy do 
    system "git add ."
    system "git commit -a -m 'Heroku Release'"
    system "git push heroku master"
  end
  
  desc "Deploy and Migrate to Heroku"
  task :deploy_migrate => :deploy do 
    system "heroku rake db:migrate"
  end
  
end