# frozen_string_literal: true

module Riddle
  NoConfigurationFileError = Class.new StandardError

  class Controller
    DEFAULT_MERGE_OPTIONS = {:filters => {}}.freeze

    attr_accessor :path, :bin_path, :searchd_binary_name, :indexer_binary_name

    def initialize(configuration, path)
      @configuration  = configuration
      @path           = path

      @bin_path            = ''
      @searchd_binary_name = 'searchd'
      @indexer_binary_name = 'indexer'
    end

    def sphinx_version
      `#{indexer} 2>&1`[/(Sphinx|Manticore) (\d+\.\d+(\.\d+|(?:-dev|(\-id64)?\-beta)))/, 2]
    rescue
      nil
    end

    def index(*indices)
      options = indices.last.is_a?(Hash) ? indices.pop : {}
      indices << '--all' if indices.empty?

      command = "#{indexer} --config \"#{@path}\" #{indices.join(' ')}"
      command = "#{command} --rotate" if running?

      Riddle::ExecuteCommand.call command, options[:verbose]
    end

    def merge(destination, source, options = {})
      options = DEFAULT_MERGE_OPTIONS.merge options

      command = "#{indexer} --config \"#{@path}\"".dup
      command << " --merge #{destination} #{source}"
      options[:filters].each do |attribute, value|
        value = value..value unless value.is_a?(Range)
        command << " --merge-dst-range #{attribute} #{value.min} #{value.max}"
      end
      command << " --rotate" if running?

      Riddle::ExecuteCommand.call command, options[:verbose]
    end

    def start(options = {})
      return if running?
      check_for_configuration_file

      command = "#{searchd} --pidfile --config \"#{@path}\""
      command = "#{command} --nodetach" if options[:nodetach]

      exec(command) if options[:nodetach]

      # Code does not get here if nodetach is true.
      Riddle::ExecuteCommand.call command, options[:verbose]
    end

    def stop(options = {})
      return true unless running?
      check_for_configuration_file

      stop_flag = 'stopwait'
      stop_flag = 'stop' if Riddle.loaded_version.split('.').first == '0'
      command = %(#{searchd} --pidfile --config "#{@path}" --#{stop_flag})

      result = Riddle::ExecuteCommand.call command, options[:verbose]
      result.successful = !running?
      result
    end

    def pid
      if File.exist?(configuration.searchd.pid_file)
        File.read(configuration.searchd.pid_file)[/\d+/]
      else
        nil
      end
    end

    def rotate
      pid && Process.kill(:HUP, pid.to_i)
    end

    def running?
      !!pid && !!Process.kill(0, pid.to_i)
    rescue
      false
    end

    private

    attr_reader :configuration

    def indexer
      "#{bin_path}#{indexer_binary_name}"
    end

    def searchd
      "#{bin_path}#{searchd_binary_name}"
    end

    def check_for_configuration_file
      return if File.exist?(@path)

      raise Riddle::NoConfigurationFileError, "'#{@path}' does not exist"
    end
  end
end
