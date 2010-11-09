# somatics.rb
# 
# repo_entered = ask 'Type your repository for the project (SVN), followed by [ENTER]:'

gem 'will_paginate', :version => "~> 3.0.pre2"
gem 'somatics3-generators', :group => :development
gem 'json'
gem 'meta_search'
gem 'paper_trail'
gem 'tiny_mce'

plugin 'faster_csv',
  :git => 'git://github.com/circle/fastercsv.git'
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

