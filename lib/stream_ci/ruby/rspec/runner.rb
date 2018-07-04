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

          root_path = StreamCi::Ruby::Rspec.root
          test_manifest = Dir["#{root_path}/**/*_spec.rb"].map do |fp|
            fp.gsub("#{root_path}/", '')
          end

          opts = { query: { api_key: '12345', branch: 'test', build: '1', test_manifest: test_manifest } }
          HTTParty.post('https://api.streamci.com/v1/tests/next', opts)

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

              opts = { query: { api_key: '12345', branch: 'test', build: '1' } }
              response = HTTParty.get('https://api.streamci.com/v1/tests/next', opts)

              until response.code == 204 || response.code >= 300 do
                # should we clear the world / example groups before each one?
                # will that mess up reporting?
                #
                # does this need to be the full path or just spec/some/spec/path ?
                if response.code == 200
                  load response.body
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
