module Fastlane
  module Actions
    class SwiftlintAction < Action
      VALID_REPORTERS = ['xcode', 'json', 'csv']

      def self.run(params)
        if `which swiftlint`.to_s.length == 0 and !Helper.test?
          raise "You have to install swiftlint using `brew install swiftlint`".red
        end

        config_file = '.swiftlint.yml'
        backup(config_file)
        update_config(config_file, params)

        command = 'swiftlint'
        command << " > #{params[:output_file]}" if params[:output_file]
        Actions.sh(command)

      ensure
        restore(config_file)
      end

      def self.backup(config_file)
        FileUtils.cp(config_file, "#{config_file}.back", preserve: true) if File.exist? config_file
      end

      def self.restore(config_file)
        if File.exist? "#{config_file}.back"
          FileUtils.cp("#{config_file}.back", config_file, preserve: true)
          FileUtils.rm("#{config_file}.back")
        else
          FileUtils.rm(config_file)
        end
      end

      def self.update_config(config_file, params)
        require 'yaml'
        lint_config = File.exist?(config_file) ? YAML.load_file(config_file) : {}
        lint_config['reporter'] = params[:reporter]
        open config_file, 'w' do |f|
          YAML.dump(lint_config, f)
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Run swift code validation using SwiftLint"
      end

      def self.details
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :output_file,
                                       description: 'Path to output SwiftLint result',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :reporter,
                                       description: 'Custom reporter of SwiftLint result',
                                       optional: true,
                                       default_value: 'xcode',
                                       verify_block: proc do |value|
                                         fail 'Unknown reporter' unless VALID_REPORTERS.include?(value)
                                       end)
        ]
      end

      def self.output
      end

      def self.return_value
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
