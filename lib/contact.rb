require 'restful_model'

module Inbox
  class Contact < RestfulModel

    attr_accessor :name
    attr_accessor :email
    attr_accessor :namespace

  end
end