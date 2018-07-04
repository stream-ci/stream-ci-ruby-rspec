require 'rake'

module StreamCi
  module Ruby
    module Rspec
      class Tasks
        include ::Rake::DSL

        def load_tasks
          rake_tasks = "#{StreamCi::Ruby::Rspec.root}/lib/tasks/*.rake"
          Dir.glob(rake_tasks).each { |rt| import rt }
        end
      end
    end
  end
end
