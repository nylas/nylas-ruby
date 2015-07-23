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

    def inflate(json)
      super
      @to ||= []
      @cc ||= []
      @bcc ||= []
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
