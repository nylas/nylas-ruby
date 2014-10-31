require 'restful_model'
require 'file'

module Inbox
  class Message < RestfulModel

    parameter :subject
    parameter :snippet
    parameter :from
    parameter :to
    parameter :cc
    parameter :bcc
    parameter :date
    parameter :thread_id
    parameter :file_ids
    parameter :body
    parameter :unread

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