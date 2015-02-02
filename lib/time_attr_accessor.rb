module Inbox
  module TimeAttrAccessor
    def time_attr_accessor(attr)
      parameter attr
      define_method "#{attr}=" do |value|
        if value
            instance_variable_set "@#{attr}", Time.at(value).utc
        end
      end
    end
  end
end