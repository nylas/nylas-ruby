require 'nylas/restful_model'

module Nylas
  class Contact < RestfulModel

    parameter :name
    parameter :email
  end
end
