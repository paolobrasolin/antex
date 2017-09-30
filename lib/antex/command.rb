# frozen_string_literal: true

require 'open3'

module Antex
  class Command
    class MissingSourceFiles < Error; end
    class MissingTargetFiles < Error; end
    class ExecutionFailed < Error; end

    def initialize(name:, sources:, targets:, command_line:)
      @name = name
      @sources = sources
      @targets = targets
      @command_line = command_line
    end

    def run!
      return if all_exist? @targets
      check_source_files!
      @stdout, @stderr, @status = Open3.capture3 @command_line
      check_status!
      check_target_files!
    end

    private

    def all_exist?(files)
      files.all?(&File.method(:exist?))
    end

    def check_source_files!
      raise MissingSourceFiles, <<~MISSING_SOURCE unless all_exist? @sources
        Required source files #{@sources.reject(&File.method(:exist?))} for command #{@name} are missing.
      MISSING_SOURCE
    end

    def check_status!
      raise ExecutionFailed, <<~EXECUTION_FAILED unless @status.success?
        Command #{command_name} failed.
        Command line: #{@command_line}
        Status: #{@status}
        Stdout:
        #{@stdout}
        Stderr:
        #{@stderr}
      EXECUTION_FAILED
    end

    def check_target_files!
      raise MissingTargetFiles, <<~MISSING_TARGET unless all_exist? @targets
        Expected target files #{@targets.reject(&File.method(:exist?))} were not produced by command #{@name}.
      MISSING_TARGET
    end
  end
end
