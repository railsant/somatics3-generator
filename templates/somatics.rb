# somatics.rb
# 
# repo_entered = ask 'Type your repository for the project (SVN), followed by [ENTER]:'

gem 'will_paginate', :version => "~> 3.0.pre2"
gem 'prawn', :version => '0.6.3'
gem 'somatics3-generators', :group => :development
gem 'json'
gem 'meta_search'
gem 'paper_trail'
gem 'tiny_mce'

plugin 'faster_csv',
  :git => 'git://github.com/circle/fastercsv.git'
plugin 'prawnto',
  :git => 'git://github.com/thorny-sun/prawnto.git'
plugin 'somatics_filter',
  :git => 'git://github.com/inspiresynergy/somatics_filter.git'
plugin 'restful_authentication',
  :git => 'git://github.com/Satish/restful-authentication.git'
plugin 'to_xls',
  :git => 'git://github.com/arydjmal/to_xls.git'
plugin 'dynamic_form', 
  :git => 'git://github.com/rails/dynamic_form.git'
plugin 'calendar_date_select',
  :git => 'git://github.com/timcharper/calendar_date_select.git'

rakefile "setup_svn.rake" do
  <<-TASK
desc "Configure Subversion for Rails"
task :setup_svn do
  system "svn info"
  if $? != 0
    puts 'Please Import your project to svn before executing this task' 
    exit(0)
  end
  
  system "svn commit -m 'initial commit'"
  
  puts "Add .gems"
  system "svn add .gems"
  system "svn commit -m 'add .gems'"
  
  puts "Add .gitignore"
  system "echo '.svn' > .gitignore"
  system "svn add .gitignore"
  system "svn commit -m 'add .gitignore'"
  
  puts "Ignoring .git"
  system "svn propset svn:ignore '.git' ."
  
  puts "Removing /log"
  system "svn remove log/*"
  system "svn commit -m 'removing all log files from subversion'"
  system 'svn propset svn:ignore "*.log" log/'
  system "svn update log/"
  system "svn commit -m 'Ignoring all files in /log/ ending in .log'"

  puts "Ignoring /db" 
  system 'svn propset svn:ignore "*.db" db/' 
  system "svn update db/" 
  system "svn commit -m 'Ignoring all files in /db/ ending in .db'"

  puts "Renaming database.yml database.example" 
  system "svn move config/database.yml config/database.example" 
  system "svn commit -m 'Moving database.yml to database.example to provide a template for anyone who checks out the code'" 
  system 'svn propset svn:ignore "database.yml" config/' 
  system "svn update config/" 
  system "svn commit -m 'Ignoring database.yml'"

  puts "Ignoring /tmp" 
  system 'svn propset svn:ignore "*" tmp/' 
  system "svn update tmp/" 
  system "svn commit -m 'Ignoring all files in /tmp/'"

  puts "Ignoring /doc" 
  system 'svn propset svn:ignore "*" doc/' 
  system "svn update doc/" 
  system "svn commit -m 'Ignoring all files in /doc/'" 
end
  TASK
end

generate "somatics:install"
# generate "tinymce_installation"
generate 'paper_trail'

environment 'config.autoload_paths += %W(#{config.root}/lib)'
generate "somatics:authenticated user"
generate "somatics:authenticated_controller admin/user --model=User"

generate "somatics:settings"

rake "db:create"
rake "db:migrate"

if yes?(%(Create Default Admin User (username:admin, password:somatics)?))
  rake "somatics:create_user" 
else
  puts "You can run rake somatics:create_user to create default user"
end

# Delete unnecessary files
run "rm README"
# run "rm public/index.html"

app_name = ARGV[0]

# Commit all work so far to the local repository
git :init 
git :add => '.'
git :commit => "-a -m 'Initial commit'"

rakefile "heroku.rake" do
  <<-TASK
namespace :heroku do
  desc "Configure Heroku"
  task :setup do
    system "heroku create #{app_name}"
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
  TASK
end

