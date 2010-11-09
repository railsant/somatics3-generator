# somatics.rb
# 
# repo_entered = ask 'Type your repository for the project (SVN), followed by [ENTER]:'

gem 'will_paginate', :version => "~> 3.0.pre2"
gem 'prawn', :version => '0.6.3'
gem 'somatics3-generators', :group => :development
gem 'json'

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

generate "somatics:install"
# generate "tinymce_installation"

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

