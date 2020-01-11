require 'rspec/core'
require 'httparty'
require 'pry'

module StreamCi
  module Ruby
    module Rspec
      class Runner < RSpec::Core::Runner
        def run_specs(example_groups)
          examples_count = @world.example_count(example_groups)
          success = @configuration.reporter.report(examples_count) do |reporter|
            @configuration.with_suite_hooks do
              # TODO
              # * what does !@world.non_example_failure return?
              # * what does @configuration.failure_exit_code return?

              @no_failures = true

              # todo set these up in an initializer or config file?
              opts = { query: { api_key: '12345', branch: 'test', build: '1' } }
              base_url = "http://#{ENV['STREAM_CI_URL']}" || 'https://api.streamci.com'
              full_url = "#{base_url}/v1/tests/next"

              # todo add better handling when a response code is 400 or greater, i.e. something went wrong

              #
              # HTTP Code 410 => Gone (i.e. there are no more tests to run, stop looking)
              #
              until ((response = HTTParty.get(full_url, opts)) && response.code >= 400) do
                # should we clear the world / example groups before each one?
                # will that mess up reporting?
                #
                # does this need to be the full path or just spec/some/spec/path ?
                if response.code == 200
                  # todo update to handle multiple test file names at somepoint? update required on API end as well
                  load response.body

                  RSpec.configuration.files_or_directories_to_run = [response.body]
                  RSpec.configuration.load_spec_files

                  unless @world.example_groups.last.run(reporter)
                    @no_failures = false
                  end
                end
              end

              @no_failures
            end
          end && !@world.non_example_failure

          success ? 0 : @configuration.failure_exit_code
        end
      end
    end
  end
end
