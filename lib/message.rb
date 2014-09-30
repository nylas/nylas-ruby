require 'restful_model'
require 'file'

module Inbox
  class Message < RestfulModel

    attr_accessor :subject
    attr_accessor :snippet
    attr_accessor :from
    attr_accessor :to
    attr_accessor :cc
    attr_accessor :bcc
    attr_accessor :date
    attr_accessor :thread_id
    attr_accessor :file_ids
    attr_accessor :body

    def inflate(json)
      super
      @file_ids ||= []
      @to ||= []
      @cc ||= []
      @bcc ||= []
    end

    def files
      @files ||= RestfulModelCollection.new(File, @_api, @namespace_id, {:message_id=>@id})
    end

  end
end