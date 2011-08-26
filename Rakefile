require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::Bundler::Error => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = 'rubygsm'
  gem.homepage = "http://github.com/adammck/rubygsm"
  gem.summary = "Send and receive SMS with a GSM modem"
	gem.authors  = ["Adam Mckaig", "Liehann Loots"]
	gem.email    = [ "adam.mckaig@gmail.com", "liehannl@gmail.com" ]
	gem.has_rdoc = true
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
end

