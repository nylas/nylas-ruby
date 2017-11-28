require_relative 'restful_model'

module Nylas
  module V1
    class Folder < RestfulModel
      parameter :display_name
      parameter :name
    end
  end
end
