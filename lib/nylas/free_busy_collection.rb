# frozen_string_literal: true

module Nylas
  # Helper to get and build `FreeBusy` objects
  class FreeBusyCollection
    extend Forwardable
    def_delegators :each, :map, :select, :reject, :to_a, :take
    def_delegators :to_a, :first, :last, :[]

    def initialize(emails:, start_time:, end_time:, api:)
      @api = api
      @emails = emails
      @start_time = start_time
      @end_time = end_time
    end

    def each
      return enum_for(:each) unless block_given?

      execute.each do |result|
        yield(FreeBusy.new(**result))
      end
    end

    private

    attr_reader :api, :emails, :start_time, :end_time

    PATH = "/calendars/free-busy"
    private_constant :PATH

    def execute
      api.execute(
        method: :post,
        path: PATH,
        payload: payload
      )
    end

    def payload
      JSON.dump(
        emails: emails,
        start_time: start_time,
        end_time: end_time
      )
    end
  end
end
