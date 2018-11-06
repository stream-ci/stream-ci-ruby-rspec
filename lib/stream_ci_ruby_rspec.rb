require 'rake/testtask'
require 'stream_ci/ruby/rspec/runner'
require 'stream_ci/ruby/rspec/tasks'
require 'stream_ci/ruby/rspec/version'
require "stream_ci/ruby/rspec/railtie" if defined?(Rails)

module StreamCi::Ruby::Rspec
  def self.root
    File.expand_path '../..', __FILE__
  end
end
