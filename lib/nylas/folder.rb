require 'nylas/restful_model'

module Nylas
  class Folder < RestfulModel

    parameter :display_name
    parameter :name

  end

  Label = Folder.clone
end
