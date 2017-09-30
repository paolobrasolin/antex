# frozen_string_literal: true

require 'open3'

module Antex
  class Pipeline
    include LiquidHelpers

    class MissingSourceFiles < Error; end
    class MissingTargetFiles < Error; end
    class FailedCommand < Error; end

    def initialize(pipeline:, commands:, binding:)
      @pipeline = pipeline
      @commands = commands
      @binding = binding
    end

    def run
      @pipeline.each do |command_name|
        run_command command_name, @commands[command_name]
      end
    end

    private

    def run_command(command_name, command)
      targets = liquid_render_array command['targets'], @binding
      # Skip if targets exist.
      return if all_exist? targets

      sources = liquid_render_array command['sources'], @binding
      # Raise if sources are missing.
      check_source_files!(sources: sources, command_name: command_name)

      # Execute command.
      command_line = liquid_render_array(command['command'], @binding).join(' ')
      stdout, stderr, status = Open3.capture3 command_line

      # Raise if command failed
      raise FailedCommand, <<~FAILED_COMMAND unless status.success?
        Command #{command_name} failed.\nCommand line: #{command_line}\nStdout:\n#{stdout}\nStderr:\n#{stderr}
      FAILED_COMMAND

      # Raise unless all targets were produced.
      check_target_files!(targets: targets, command_name: command_name)
    end

    def all_exist?(files)
      files.all?(&File.method(:exist?))
    end

    def check_source_files!(sources:, command_name:)
      raise MissingSourceFiles, <<~MISSING_SOURCE unless all_exist? sources
        Source files #{sources.reject(&File.method(:exist?))} missing for command #{command_name}.
      MISSING_SOURCE
    end

    def check_target_files!(targets:, command_name:)
      raise MissingTargetFiles, <<~MISSING_TARGET unless all_exist? targets
        Target files #{targets.reject(&File.method(:exist?))} not produced by command #{command_name}.
      MISSING_TARGET
    end
  end
end
