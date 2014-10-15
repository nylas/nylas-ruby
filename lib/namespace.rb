require 'restful_model'
require 'tag'
require 'message'
require 'draft'
require 'contact'
require 'file'
require 'calendar'
require 'event'

# Rather than saying require 'thread', we need to explicitly force
# the thread model to load. Otherwise, we can't reference it below.
# Thread still refers to the built-in Thread type, and Inbox::Thread
# is undefined.
load "thread.rb"

module Inbox

  class Namespace < RestfulModel

    parameter :account_id
    parameter :email_address
    parameter :provider

    def self.collection_name
      "n"
    end

    def threads
      @threads ||= RestfulModelCollection.new(Thread, @_api, @id)
    end

    def tags
      @tags ||= RestfulModelCollection.new(Tag, @_api, @id)
    end

    def messages
      @messages ||= RestfulModelCollection.new(Message, @_api, @id)
    end

    def files
      @files ||= RestfulModelCollection.new(File, @_api, @id)
    end

    def drafts
      @drafts ||= RestfulModelCollection.new(Draft, @_api, @id)
    end

    def contacts
      @contacts ||= RestfulModelCollection.new(Contact, @_api, @id)
    end

    def calendars
      @calendars ||= RestfulModelCollection.new(Calendar, @_api, @id)
    end

    def events
      @events ||= RestfulModelCollection.new(Event, @_api, @id)
    end

  end
end