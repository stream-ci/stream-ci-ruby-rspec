require 'rspec/core'
require 'httparty'
require 'json'
require 'pry'

module StreamCi
  module Ruby
    module Rspec
      class Runner < RSpec::Core::Runner
        def setup(err, out)
          @configuration.error_stream = err
          @configuration.output_stream = out if @configuration.output_stream == $stdout
          @options.configure(@configuration)

          @configuration.output_stream.print(
            "#\n# Preparing test manifest to send to StreamCI\n#\n"
          )
          t1 = Time.now

          project_root = Rails.root.to_s # this needs to be setup via a config option, as non-rails apps might use this
          spec_root = '/spec' # pull from rspec config?
          test_manifest = Dir["#{project_root}#{spec_root}/**/*_spec.rb"].map do |fp|
            fp.gsub("#{project_root}/", '')
          end

          opts = {
            query: {
              api_key: '12345',
              branch: 'test',
              build: '1',
              test_manifest: test_manifest & @options.args
            }
          }

          stream_ci_url = ENV['STREAM_CI_URL'] || 'https://api.streamci.com'
          HTTParty.post("#{stream_ci_url}/v1/tests", opts)

          t2 = Time.now
          @configuration.output_stream.print "#\n# Test manifest sent to StreamCI - (#{((t2 - t1) * 1000).round} ms)\n#\n"

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
              stream_ci_url = ENV['STREAM_CI_URL'] || 'https://api.streamci.com'
              response = HTTParty.get("#{stream_ci_url}/v1/tests/next", opts)

              binding.pry
              until response.code == 204 || response.code >= 300 do
                # should we clear the world / example groups before each one?
                # will that mess up reporting?
                #
                # does this need to be the full path or just spec/some/spec/path ?
                binding.pry
                if response.code == 200
                  puts "Running #{response.body}"
                  binding.pry
                  load JSON.parse(response.body)['test']
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