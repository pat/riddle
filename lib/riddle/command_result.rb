class Riddle::CommandResult
  attr_accessor :status, :output, :successful

  def initialize(status, output = nil, successful = true)
    @status, @output, @successful = status, output, successful
  end
end
