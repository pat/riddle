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
    verbose? ? result_from_system : result_from_backticks
  end

  private

  attr_reader :command, :verbose

  def result_from_backticks
    output = `#{command}`

    Riddle::CommandResult.new $?.exitstatus, output
  end

  def result_from_system
    system command

    Riddle::CommandResult.new $?.exitstatus
  end

  def verbose?
    verbose
  end
end
