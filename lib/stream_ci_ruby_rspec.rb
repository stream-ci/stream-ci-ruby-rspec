require 'rake/testtask'
require 'stream_ci/ruby/rspec/version'

# require 'stream_ci_ruby_rspec/version'

# a_proc = Proc.new {|a, *b| b.collect {|i| i*a }}
# a_proc.call(9, 1, 2, 3)   #=> [9, 18, 27]
# a_proc[9, 1, 2, 3]        #=> [9, 18, 27]
# a_proc = lambda {|a,b| a}
# a_proc.call(1,2,3)
#
# # @param args [Array] command-line-supported arguments
# # @param err [IO] error stream
# # @param out [IO] output stream
# # @return [Fixnum] exit status code. 0 if all specs passed,
# #   or the configured failure exit code (1 by default) if specs
# #   failed.
# def self.run(args, err=$stderr, out=$stdout)
#   trap_interrupt
#   options = ConfigurationOptions.new(args)
#
#   if options.options[:runner]
#     options.options[:runner].call(options, err, out)
#   else
#     new(options).run(err, out)
#   end
# end
#
# class StreamCI::Ruby::Rspec::Runner
#   def initialize(options); end
# end
#
# args[:runner] = Proc.new do |options, err, out|
#   StreamCI::Ruby::Rspec::Runner.new(options).run(err, out)
# end
#

# `rake streamci:ruby:rspec`
#
# StreamCI::Ruby::Rspec::Runner.invoke
#
# class StreamCI::Ruby::Rspec::Runner < Rspec::Core::Runner
#   # see Apoc::Runner
# end
