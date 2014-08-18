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
    attr_accessor :thread
    attr_accessor :files
    attr_accessor :body
    attr_accessor :namespace

    def files
      @files ||= RestfulModelCollection.new(File, @_api, {:message=>@id})
    end

  end
end