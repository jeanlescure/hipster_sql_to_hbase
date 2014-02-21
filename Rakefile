require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
    gem.name = "hipster_sql_to_hbase"
    gem.homepage = "http://github.com/jeanlescure/hipster_sql_to_hbase"
    gem.license = "MIT"
    gem.summary = %Q{SQL to HBase parser using Treetop (output based on Thrift).}
    gem.description = %Q{SQL to HBase parser using Treetop (output based on Thrift).}
    gem.email = "jeanmlescure@gmail.com"
    gem.authors = ["Jean Lescure"]
    # dependencies defined in Gemfile
  end
  Jeweler::RubygemsDotOrgTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hipster_sql_to_hbase #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
