require 'stream_ci_ruby_rspec'

namespace :stream_ci do
  namespace :ruby do
    namespace :rspec do
      desc 'Run and report on RSpec specs via StreamCI'
      task :run, [:rspec_args] do |_, args|
        StreamCi::Ruby::Rspec::Runner.run(args[:rspec_args])
      end
    end
  end
end