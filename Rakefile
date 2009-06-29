# 
# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "rupper Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "mappum"
    gemspec.summary = "Mappum is the tree to tree (object, bean etc.) mapping DSL."
    gemspec.email = "jtopinski@chatka.org"
    gemspec.homepage = "http://wiki.github.com/simcha/mappum"
    gemspec.description = ""
    gemspec.authors = ["Jan Topiński"]
    gemspec.add_dependency('facets', '>= 2.5.2')
    gemspec.add_dependency('soap4r', '>= 1.5.8')
    gemspec.add_dependency('sinatra', '>= 0.9.2')
    gemspec.add_dependency('thin', '>= 1.2.2')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

