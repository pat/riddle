# frozen_string_literal: true

class Riddle::CommandResult
  attr_reader   :command, :status, :output
  attr_accessor :successful

  def initialize(command, status, output = nil, successful = nil)
    @command, @status, @output = command, status, output

    if successful.nil?
      @successful = (@status == 0)
    else
      @successful = successful
    end
  end
end
