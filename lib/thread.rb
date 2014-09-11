require 'restful_model'
require 'time_attr_accessor'

module Inbox
  class Thread < RestfulModel
    extend TimeAttrAccessor

    attr_accessor :subject
    attr_accessor :participants
    attr_accessor :snippet
    attr_accessor :tags
    attr_accessor :message_ids
    attr_accessor :draft_ids
    time_attr_accessor :last_message_timestamp
    time_attr_accessor :first_message_timestamp

    def messages
      @messages ||= RestfulModelCollection.new(Message, @_api, @namespace_id, {:thread_id=>@id})
    end

    def drafts
      @drafts ||= RestfulModelCollection.new(Draft, @_api, @namespace_id, {:thread_id=>@id})
    end

    def update_tags!(tags_to_add = [], tags_to_remove = [])
      update('PUT', '', {
        :add_tags => tags_to_add,
        :remove_tags => tags_to_remove
      })
    end

    def mark_as_read!
      update_tags!([], ['unread'])
    end

    def mark_as_seen!
      update_tags!([], ['unseen'])
    end

    def archive!
      update_tags!(['archive'], ['inbox'])
    end

    def unarchive!
      update_tags!(['inbox'], ['archive'])
    end

    def star!
      update_tags!(['starred'], [''])
    end

    def unstar!
      update_tags!([], ['starred'])
    end
  end
end