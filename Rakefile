require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "somatics3-generators"
    gem.summary = %Q{Somatics - Adminable Resource generators}
    gem.description = %Q{Somatics 3 generators is used to generate a resource with skeleton admin panel}
    gem.email = "tkwong@inspiresynergy.com"
    gem.homepage = "http://github.com/inspiresynergy/somatics3-generators"
    gem.authors = ["Benjamin Wong"]
    # gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.rdoc_options += FileList['lib/**/templates/*'].to_a.collect{|f| "--exclude=#{f}" }
    # gem.files = FileList[
    #         "README.rdoc"
    # ]
    # raise FileList['lib/**/templates/*'].to_a.collect{|f| "--exclude=#{f}" }.inspect
    # gem.rdoc_options << "--exclude='lib/**/templates/*'"
    gem.rubyforge_project = 'somatics3'
    gem.add_dependency 'will_paginate', "~> 3.0.pre2"
    gem.add_dependency 'json'
    gem.add_dependency 'meta_search'
    gem.add_dependency 'paper_trail'
    gem.add_dependency 'tiny_mce'
    gem.add_dependency 'devise'
    # gem.add_dependency 'prawn', "0.6.3"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "somatics3-generators #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.exclude('lib/**/templates/*')
end
