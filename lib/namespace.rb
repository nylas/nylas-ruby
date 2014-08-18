require 'restful_model'
require 'tag'
require 'message'
require 'draft'
require 'contact'
require 'file'

# Rather than saying require 'thread', we need to explicitly force
# the thread model to load. Otherwise, we can't reference it below.
# Thread still refers to the built-in Thread type, and Inbox::Thread
# is undefined.
load "thread.rb"

module Inbox

  class Namespace < RestfulModel

    attr_accessor :email_address
    attr_accessor :provider
    attr_accessor :account

    def self.collection_name
      "n"
    end

    def threads
      @threads ||= RestfulModelCollection.new(Thread, @_api, self)
    end

    def tags
      @tags ||= RestfulModelCollection.new(Tag, @_api, self)
    end

    def messages
      @messages ||= RestfulModelCollection.new(Message, @_api, self)
    end

    def files
      @files ||= RestfulModelCollection.new(File, @_api, self)
    end

    def drafts
      @drafts ||= RestfulModelCollection.new(Draft, @_api, self)
    end

    def contacts
      @contacts ||= RestfulModelCollection.new(Contact, @_api, self)
    end

  end
end