# frozen_string_literal: true

require 'mysql2'

module Riddle::SQLClient
  class Mysql2 < ::Mysql2::Client
  end
end
