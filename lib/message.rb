require 'restful_model'
require 'file'
require 'rfc2882'

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
    parameter :body
    parameter :unread
    parameter :starred
    parameter :folder
    parameter :labels

    def inflate(json)
      super
      @to ||= []
      @cc ||= []
      @bcc ||= []
      @labels ||= []
      @folder ||= nil

      # This is a special case --- we receive label data from the API
      # as JSON but we want it to behave like an API object.
      @labels.map! do |label_json|
       label = Label.new(@_api)
       label.inflate(label_json)
       label
      end

      if not folder.nil?
       folder = folder.new(@_api)
       folder.inflate(@folder)
       @folder = folder
      end
    end

    def as_json(options = {})
      hash = {}

      # unread, starred and labels/folder are the only attribute
      # you can modify.
      if not @unread.nil?
        hash["unread"] = @unread
      end

      if not @starred.nil?
        hash["starred"] = @starred
      end

      if not @labels.nil? and @labels != []
        hash["labels"] = @labels.map do |label|
          label.id
        end
      end

      if not @folder.nil?
        hash["folder"] = @folder.id
      end

      hash
    end

    def files
      @files ||= RestfulModelCollection.new(File, @_api, @namespace_id, {:message_id=>@id})
    end

    def raw
      model = nil
      collection = RestfulModelCollection.new(Message, @_api, @namespace_id, {:message_id=>@id})
      RestClient.get("#{collection.url}/#{id}/rfc2822"){ |response,request,result|
        json = Inbox.interpret_response(result, response, {:expected_class => Object})
        model = Rfc2822.new(@_api)
        model.inflate(json)
      }
      model
    end
  end
end
