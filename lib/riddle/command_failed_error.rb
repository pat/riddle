# frozen_string_literal: true

class Riddle::CommandFailedError < StandardError
  attr_accessor :command_result
end
