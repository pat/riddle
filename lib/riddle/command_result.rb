class Riddle::CommandResult
  attr_reader   :command, :status, :output
  attr_accessor :successful

  def initialize(command, status, output = nil, successful = true)
    @command, @status, @output, @successful =
      command, status, output, successful
  end
end
