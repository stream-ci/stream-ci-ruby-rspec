require 'rspec/core'
require 'httparty'

module StreamCi
  module Ruby
    module Rspec
      class Runner < RSpec::Core::Runner
        def setup(err, out)
          @configuration.error_stream = err
          @configuration.output_stream = out if @configuration.output_stream == $stdout
          @options.configure(@configuration)

          # TODO
          # * What do these commands do / mean?
          #
          # @configuration.load_spec_files
          # @world.announce_filters
        end

        def run_specs(example_groups)
          examples_count = @world.example_count(example_groups)
          success = @configuration.reporter.report(examples_count) do |reporter|
            @configuration.with_suite_hooks do
              # TODO
              # * what does !@world.non_example_failure return?
              # * what does @configuration.failure_exit_code return?

              @no_failures = true

              #
              # until the return status code is 204, keep pulling data
              #

              opts = { query: { api_key: '12345' } } # need to include other params as well
              response = HTTParty.get('https://api.streamci.com/v1/results', opts)

              # until (file_path = open(stream_ci_url).read) == '>>done<<' do
              until response.code == 204 do
                # should we clear the world / example groups before each one?
                # will that mess up reporting?
                #
                # does this need to be the full path or just spec/some/spec/path ?
                load response.body
                unless @world.example_groups.last.run(reporter)
                  @no_failures = false
                end
              end

              @no_failures
            end
          end && !@world.non_example_failure

          success ? 0 : @configuration.failure_exit_code
        end

        private

        def stream_ci_url

        end
      end
    end
  end
end
