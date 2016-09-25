class Riddle::CommandFailedError < StandardError
  attr_accessor :command_result
end
