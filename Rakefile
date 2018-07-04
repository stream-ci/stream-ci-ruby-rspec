require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'stream_ci_ruby_rspec'

StreamCi::Ruby::Rspec::Tasks.new.load_tasks

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
