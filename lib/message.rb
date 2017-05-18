require 'restful_model'
require 'file'
require 'mixins'

module Nylas
  class Message < RestfulModel

    parameter :subject
    parameter :snippet
    parameter :from
    parameter :to
    parameter :reply_to
    parameter :cc
    parameter :bcc
    parameter :date
    parameter :thread_id
    parameter :body
    parameter :unread
    parameter :starred
    parameter :folder
    parameter :labels
    parameter :tracking

    include Nylas::ReadUnreadMethods

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

      if not folder.nil? and folder.is_a?(Hash)
       folder = Folder.new(@_api)
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
        hash["label_ids"] = @labels.map do |label|
          label.id
        end
      end

      if not @folder.nil?
        hash["folder_id"] = @folder.id
      end

      hash
    end

    def files
      @files ||= RestfulModelCollection.new(File, @_api, {:message_id=>@id})
    end

    def files?
      !@raw_json['files'].empty?
    end

    def raw
      collection = RestfulModelCollection.new(Message, @_api, {:message_id=>@id})
      RestClient.get("#{collection.url}/#{id}/", :accept => 'message/rfc822'){ |response,request,result|
        Nylas.interpret_response(result, response, {:raw_response => true})
        response
      }
    end

    def expanded
      expanded_url = url(action='?view=expanded')

      RestClient.get(expanded_url){ |response,request,result|
        json = Nylas.interpret_response(result, response, :expected_class => Object)
        expanded_message = Nylas::ExpandedMessage.new(@_api)
        expanded_message.inflate(json)
        expanded_message
      }

    end
  end
end
