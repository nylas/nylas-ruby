require 'restful_model'

module Inbox
  class Account < RestfulModel

    attr_accessor :account_id
    attr_accessor :trial
    attr_accessor :trial_expires
    attr_accessor :sync_state

    def initialize(params = {})
      @account_id = params.fetch(:account_id, '')
      @trial = params.fetch(:trial, '')
      @trial_expires = params.fetch(:trial_expires, '')
      @sync_state = params.fetch(:sync_state, '')
    end

  end
end
