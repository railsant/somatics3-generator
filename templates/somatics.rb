# somatics.rb
# 
# repo_entered = ask 'Type your repository for the project (SVN), followed by [ENTER]:'

app_name = ARGV[0]

puts "         Somatics going to bootstrap your new #{app_name.humanize} App..."
puts "         Any problems? See https://github.com/inspiresynergy/somatics3-generator"


#----------------------------------------------------------------------------
# Set up git
#----------------------------------------------------------------------------
puts "         setting up source control with 'git'..."
# specific to Mac OS X
append_file '.gitignore' do
  '.DS_Store'
end
git :init
git :add => '.'
git :commit => "-m 'Initial commit of unmodified new Rails app'"

#----------------------------------------------------------------------------
# Add Somatics Required Gems and plugins
#----------------------------------------------------------------------------

gem 'will_paginate', :version => "~> 3.0.pre2"
gem 'somatics3-generators', :group => :development
gem 'json'
gem 'meta_search'
gem 'paper_trail'
gem 'tiny_mce'
gem 'devise'

puts "         installing gems (takes a few minutes!)..."
run 'bundle install'

plugin 'faster_csv',
  :git => 'git://github.com/circle/fastercsv.git'
plugin 'somatics_filter',
  :git => 'git://github.com/inspiresynergy/somatics_filter.git'
plugin 'to_xls',
  :git => 'git://github.com/arydjmal/to_xls.git'
plugin 'dynamic_form', 
  :git => 'git://github.com/rails/dynamic_form.git'
plugin 'calendar_date_select',
  :git => 'git://github.com/timcharper/calendar_date_select.git'

#----------------------------------------------------------------------------
# Tweak config/application.rb
#----------------------------------------------------------------------------
environment 'config.autoload_paths += %W(#{config.root}/lib)'

#----------------------------------------------------------------------------
# Remove the usual cruft
#----------------------------------------------------------------------------
puts "         removing unneeded files..."
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/images/rails.png'
run 'rm README'
run 'touch README'

puts "         banning spiders from your site by changing robots.txt..."
gsub_file 'public/robots.txt', /# User-Agent/, 'User-Agent'
gsub_file 'public/robots.txt', /# Disallow/, 'Disallow'

#----------------------------------------------------------------------------
# Generate Required Assets
#----------------------------------------------------------------------------

generate "somatics:install"
generate "devise:install"
generate 'paper_trail'
generate "somatics:authenticated user --namespace=admin"
generate "somatics:settings"

#----------------------------------------------------------------------------
# Create and Migrate the Database
#----------------------------------------------------------------------------

puts "         create and migrate the database"
rake "db:create"
rake "db:migrate"
rake "db:seed"

#----------------------------------------------------------------------------
# Create a default user
#----------------------------------------------------------------------------

if yes?(%(Create Default Admin User (email:admin@somatics.com, password:somatics)?))
  rake "somatics:create_user" 
else
  puts "         You can run rake somatics:create_user to create default user"
end

#----------------------------------------------------------------------------
# Finish up
#----------------------------------------------------------------------------

puts "         checking everything into git..."
git :add => '.'
git :commit => "-m 'modified Rails app to use Somatics'"

puts "         Done setting up your Rails app with Somatics."

