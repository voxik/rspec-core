require 'optparse'
# http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html

module Rspec
  module Core

    class CommandLineOptions
      DEFAULT_OPTIONS_FILE = 'spec/spec.opts'
      DEFAULT_SPEC_DIRECTORY = 'spec'
      
      attr_reader :args, :options
      
      def self.parse(args)
        new(args).parse
      end

      def initialize(args)
        @args = args
        @options = {}
      end
      
      def parse
        parse_command_line_args
        display_usage unless files_given? or default_directory_exists?
        self
      end

      def parse_command_line_args
        options[:files_or_directories_to_run] = parser.parse(@args)
      end

      def files_given?
        !@options[:files_or_directories_to_run].empty?
      end

      def default_directory_exists?
        @options[:files_or_directories_to_run] << DEFAULT_SPEC_DIRECTORY if File.directory?(DEFAULT_SPEC_DIRECTORY)
      end

      def display_usage
        puts parser
        exit
      end

      def apply(config)
        # 1) option file, cli options, rspec core configure
        # TODO: Add options_file to configuration
        # TODO: Store command line options for reference
        options_file = options.delete(:options_file) || DEFAULT_OPTIONS_FILE
        merged_options = parse_spec_file_contents(options_file).merge!(options)
        options.replace merged_options
        
        options.each do |key, value|
          config.send("#{key}=", value)
        end
      end

    private

      def parser
        @parser ||= OptionParser.new do |parser|
          parser.banner = "Usage: rspec [options] [files or directories]"

          parser.on('-c', '--[no-]color', '--[no-]colour', 'Enable color in the output') do |o|
            options[:color_enabled] = o
          end
          
          parser.on('-f', '--formatter [FORMATTER]', 'Choose a formatter',
                  '  [p]rogress (default - dots)',
                  '  [d]ocumentation (group and example names)') do |o|
            options[:formatter] = o
          end

          parser.on('-l', '--line_number [LINE]', 'Specify the line number of a single example to run') do |o|
            options[:line_number] = o
          end

          parser.on('-e', '--example [PATTERN]', "Run examples whose full descriptions match this pattern",
                  "(PATTERN is compiled into a Ruby regular expression)") do |o|
            options[:full_description] = /#{o}/
          end

          parser.on('-o', '--options [PATH]', 'Read configuration options from a file path.  (Defaults to spec/spec.parser)') do |o|
            options[:options_file] = o || DEFAULT_OPTIONS_FILE
          end

          parser.on('-p', '--profile', 'Enable profiling of examples with output of the top 10 slowest examples') do |o|
            options[:profile_examples] = o
          end

          parser.on('-b', '--backtrace', 'Enable full backtrace') do |o|
            options[:full_backtrace] = true
          end

          parser.on('-d', '--debug', 'Enable debugging') do |o|
            options[:debug] = true
          end
          
          parser.on_tail('-h', '--help', "You're looking at it.") do 
            display_usage
          end
        end
      end

      def parse_spec_file_contents(options_file)
        return {} unless File.exist?(options_file)
        spec_file_contents = File.readlines(options_file).map {|l| l.split}.flatten
        self.class.new(spec_file_contents).parse.options
      end
    end

  end
end
