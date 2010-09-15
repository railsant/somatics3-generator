# somatics.rb

# app_name = ask 'Type your Application Name for the Heroku project, followed by [ENTER]:'
# 
# repo_entered = ask 'Type your repository for the project (SVN), followed by [ENTER]:'

gem 'will_paginate', :version => "~> 3.0.pre2"
gem 'prawn', :version => '0.6.3'
gem 'somatics3-generators'
gem 'json'

rake "gems:install", :sudo => true

plugin 'action_mailer_optional_tls',
  :git => 'git://github.com/collectiveidea/action_mailer_optional_tls.git'
plugin 'faster_csv',
  :git => 'git://github.com/circle/fastercsv.git'
plugin 'prawnto',
  :git => 'git://github.com/thorny-sun/prawnto.git'
plugin 'redmine_filter',
  :git => 'git://github.com/inspiresynergy/redmine_filter.git'
plugin 'restful_authentication',
  :git => 'git://github.com/Satish/restful-authentication.git'
  # :git => 'git://github.com/technoweenie/restful-authentication.git'
# plugin 'somatics_generator',
#   :git => 'git://github.com/inspiresynergy/somatics_generator.git'
# theme_support break my rails 2.3.5 
# http://inspiresynergy.lighthouseapp.com/projects/53315-somatics/tickets/14-theme_support-break-my-rails-235
 # plugin 'theme_support',
 #   :git => 'git://github.com/aussiegeek/theme_support.git'
plugin 'tinymce_hammer',
  :git => 'git://github.com/trevorrowe/tinymce_hammer.git'
plugin 'to_xls',
  :git => 'git://github.com/arydjmal/to_xls.git'
plugin 'dynamic_form', 
  :git => 'git://github.com/rails/dynamic_form.git'

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
environment 'config.autoload_paths += %W(#{config.root}/lib)'
generate "somatics:authenticated user"
generate "somatics:authenticated_controller admin/user --model=User"

run %(rails runner "User.create(:name => 'Admin', :login => 'admin', :password => 'somatics', :password_confirmation => 'somatics', :email => 'admin@admin.com')")

# 
# generate "tinymce_installation"
# generate "admin_controllers"
# generate "admin_scaffold user --admin-authenticated"
# generate "admin_setting"
# 
# rake "db:create"
# rake "db:migrate"

# unless app_name.blank?
#   run "git init"
#   rake "heroku:gems"
#   run "heroku create #{app_name}"
#   run "git add ."
#   run "git commit -a -m 'Initial Commit' "
#   run "heroku addons:add cron:daily"
#   run "heroku addons:add deployhooks:email \
#       recipient=heroku@inspiresynergy.com \
#       subject=\"#{app_name} Deployed\" \
#       body=\"{{user}} deployed app\""
#   run "heroku addons:add piggyback_ssl"
#   run "heroku addons:add newrelic:bronze"
#   run "heroku addons:add cron:daily"
#   run "git push heroku master"
#   run "heroku rake db:migrate"
# end
# 
# unless repo_entered.blank?
#   run "svn co #{repo_entered}"
#   rake "setup_svn"
# end
