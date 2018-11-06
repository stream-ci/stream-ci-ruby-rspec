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

          # set manifest based on args files/directories or default test directory/directories

          binding.pry
          # targets =

          # OLD Setup

          # this needs to be setup via a config option, as non-rails apps might use this
          project_root = Rails.root.to_s

          # pull from rspec config?
          spec_root = '/spec'

          test_manifest = Dir["#{project_root}#{spec_root}/**/*_spec.rb"].map do |fp|
            fp.gsub("#{project_root}/", '')
          end

          # this does not currently handle directories -- need to fix.
          given_files_or_directories = if @options.args.any?
                                         @options.args.first.split(" ")
                                       else
                                         []
                                       end

          if given_files_or_directories.any?
            test_manifest = test_manifest & given_files_or_directories
          end

          # OLD Setup - end

          opts = {
            query: {
              api_key: '12345',
              branch: 'test',
              build: '1',
              test_manifest: test_manifest
            }
          }

          base_url = "http://#{ENV['STREAM_CI_URL']}" || 'https://api.streamci.com'
          full_url = "#{base_url}/v1/tests"
          HTTParty.post(full_url, opts)

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
              base_url = "http://#{ENV['STREAM_CI_URL']}" || 'https://api.streamci.com'
              full_url = "#{base_url}/v1/tests/next"

              until ((response = HTTParty.get(full_url, opts)) && (response.code == 204 || response.code >= 300)) do
                # should we clear the world / example groups before each one?
                # will that mess up reporting?
                #
                # does this need to be the full path or just spec/some/spec/path ?
                if response.code == 200
                  load JSON.parse(response.body)['test']

                  RSpec.configuration.files_or_directories_to_run = [JSON.parse(response.body)['test']]
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
