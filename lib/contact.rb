require 'restful_model'

module Inbox
  class Contact < RestfulModel

    parameter :name
    parameter :email

  end
end