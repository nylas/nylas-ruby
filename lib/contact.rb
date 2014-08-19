require 'restful_model'

module Inbox
  class Contact < RestfulModel

    attr_accessor :name
    attr_accessor :email

  end
end