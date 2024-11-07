# frozen_string_literal: true

require_relative "resources/calendars"
require_relative "resources/connectors"
require_relative "resources/messages"
require_relative "resources/events"
require_relative "resources/auth"
require_relative "resources/webhooks"
require_relative "resources/applications"
require_relative "resources/folders"
require_relative "resources/scheduler"

module Nylas
  # Methods to retrieve data from the Nylas API as Ruby objects.
  class Client
    attr_reader :api_key, :api_uri, :timeout

    # Initializes a client session.
    #
    # @param api_key [String, nil] API key to use for the client session.
    # @param api_uri [String] Client session's host.
    # @param timeout [Integer, nil] Timeout value to use for the client session.
    def initialize(api_key:,
                   api_uri: Config::DEFAULT_REGION_URL,
                   timeout: nil)
      @api_key = api_key
      @api_uri = api_uri
      @timeout = timeout || 90
    end

    # The application resources for your Nylas application.
    #
    # @return [Nylas::Applications] Application resources for your Nylas application.
    def applications
      Applications.new(self)
    end

    # The attachments resources for your Nylas application.
    #
    # @return [Nylas::Attachments] Attachment resources for your Nylas application.
    def attachments
      Attachments.new(self)
    end

    # The auth resources for your Nylas application.
    #
    # @return [Nylas::Auth] Auth resources for your Nylas application.
    def auth
      Auth.new(self)
    end

    # The calendar resources for your Nylas application.
    #
    # @return [Nylas::Calendars] Calendar resources for your Nylas application.
    def calendars
      Calendars.new(self)
    end

    # The connector resources for your Nylas application.
    #
    # @return [Nylas::Connectors] Connector resources for your Nylas application.
    def connectors
      Connectors.new(self)
    end

    # The contact resources for your Nylas application.
    #
    # @return [Nylas::Contacts] Contact resources for your Nylas application.
    def contacts
      Contacts.new(self)
    end

    # The draft resources for your Nylas application.
    #
    # @return [Nylas::Drafts] Draft resources for your Nylas application.
    def drafts
      Drafts.new(self)
    end

    # The event resources for your Nylas application.
    #
    # @return [Nylas::Events] Event resources for your Nylas application
    def events
      Events.new(self)
    end

    # The folder resources for your Nylas application.
    #
    # @return [Nylas::Folder] Folder resources for your Nylas application
    def folders
      Folders.new(self)
    end

    # The grants resources for your Nylas application.
    #
    # @return [Nylas::Grants] Grant resources for your Nylas application
    def grants
      Grants.new(self)
    end

    # The message resources for your Nylas application.
    #
    # @return [Nylas::Messages] Message resources for your Nylas application
    def messages
      Messages.new(self)
    end

    # The thread resources for your Nylas application.
    #
    # @return [Nylas::Threads] Thread resources for your Nylas application.
    def threads
      Threads.new(self)
    end

    # The webhook resources for your Nylas application.
    #
    # @return [Nylas::Webhooks] Webhook resources for your Nylas application.
    def webhooks
      Webhooks.new(self)
    end

    # The Scheduler resources for your Nylas application.
    # @return [Nylas::Scheduler] Scheduler resources for your Nylas application.
    def scheduler
      Scheduler.new(self)
    end
  end
end
