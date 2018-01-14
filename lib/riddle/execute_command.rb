# frozen_string_literal: true

class Riddle::ExecuteCommand
  WINDOWS = (RUBY_PLATFORM =~ /mswin|mingw/)

  def self.call(command, verbose = true)
    new(command, verbose).call
  end

  def initialize(command, verbose)
    @command, @verbose = command, verbose

    return unless WINDOWS

    @command = "start /B #{@command} 1> NUL 2>&1"
    @verbose = true
  end

  def call
    result = verbose? ? result_from_system : result_from_backticks
    return result if result.status == 0

    error = Riddle::CommandFailedError.new "Sphinx command failed to execute"
    error.command_result = result
    raise error
  end

  private

  attr_reader :command, :verbose

  def result_from_backticks
    begin
      output = `#{command}`
    rescue SystemCallError => error
      output = error.message
    end

    Riddle::CommandResult.new command, $?.exitstatus, output
  end

  def result_from_system
    system command

    Riddle::CommandResult.new command, $?.exitstatus
  end

  def verbose?
    verbose
  end
end
