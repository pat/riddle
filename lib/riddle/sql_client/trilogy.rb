# frozen_string_literal: true

require 'trilogy'

module Riddle::SQLClient
  class Trilogy < ::Trilogy
    def query(statement)
      super.each_hash.to_a
    end
  end
end
