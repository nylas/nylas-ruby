# We are explicitely choosing to allow clients to use or not use informed at their discretion
# rubocop:disable Lint/HandleExceptions
begin
  require "informed"
rescue LoadError
end
# rubocop:enable Lint/HandleExceptions

module Nylas
  # Exposes a shared logger for debugging purposes
  module Logging
    def self.included(object)
      if const_defined? :Informed
        object.include Informed
        Informed.logger = logger
      else
        object.extend NoOpInformOn
      end
    end

    def self.logger
      return @logger if @logger
      @logger = Logger.new(STDOUT)
      @logger.level = level
      @logger
    end

    def self.level
      Logger.const_get(ENV["NYLAS_LOG_LEVEL"] || :WARN)
    end

    def self.logger=(logger)
      @logger = logger
    end

    # No op for inform_on if user does not have the informed gem installed.
    module NoOpInformOn
      def inform_on(method, level: :debug, also_log: {}); end
    end
  end
end
