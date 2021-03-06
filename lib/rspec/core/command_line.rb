module RSpec
  module Core
    class CommandLine
      def initialize(options, configuration=RSpec::configuration, world=RSpec::world)
        options.configure(configuration)
        configuration.require_files_to_run
        configuration.configure_mock_framework
        @configuration = configuration
        @options = options
        @world = world
      end

      def run(err, out)
        @configuration.error_stream = err
        @configuration.output_stream = out
        @world.announce_inclusion_filter

        @configuration.reporter.report(example_count) do |reporter|
          begin
            @configuration.run_hook(:before, :suite)
            example_groups.run_examples(reporter)
          ensure
            @configuration.run_hook(:after, :suite)
          end
        end

        example_groups.success?
      end

    private

      def example_count
        @world.example_count
      end

      module ExampleGroups
        def run_examples(reporter)
          @success = self.inject(true) {|success, group| success &= group.run(reporter)}
        end

        def success?
          @success ||= false
        end
      end

      def example_groups
        @world.example_groups.extend(ExampleGroups)
      end
    end
  end
end
