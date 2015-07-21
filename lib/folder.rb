require 'restful_model'

module Inbox
  class Folder < RestfulModel

    parameter :display_name
    parameter :name

  end

  Label = Folder.clone
end
