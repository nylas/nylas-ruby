require_relative 'restful_model'

module Nylas
  module V1
    class Contact < RestfulModel
      parameter :name
      parameter :email
    end
  end
end
