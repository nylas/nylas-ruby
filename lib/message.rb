require 'restful_model'
require 'file'

module Inbox
  class Message < RestfulModel

    attr_accessor :subject
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
      @thread_id = json[:thread]
      @file_ids = json[:files] || []
      @to ||= []
      @cc ||= []
      @bcc ||= []
    end

    def as_json()
      json = super
      json[:files] = json[:file_ids]
      json
    end

    def files
      @files ||= RestfulModelCollection.new(File, @_api, @namespace, {:message=>@id})
    end

  end
end