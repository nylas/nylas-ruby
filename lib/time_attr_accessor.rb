module Inbox
  module TimeAttrAccessor
    def time_attr_accessor(attr)
      attr_reader attr
      define_method "#{attr}=" do |value|
        instance_variable_set "@#{attr}", Time.at(value).utc
      end
    end
  end
end