module Nylas
  module Parameters
    def self.included(base)
      base.extend(ClassMethods)
    end

    def parameters
      self.class.instance_variable_get("@parameters")
    end

    module ClassMethods
      def parameter(*params)
        @parameters ||= []
        params.each do |param|
          define_method param do
            model_state[param]
          end

          define_method :"#{param}=" do |value|
            model_state[param] = value
          end
          @parameters << param.to_s
        end
      end

      def inherited(subclass)
        parameters = instance_variable_get("@parameters") || []
        subclass.instance_variable_set("@parameters", parameters.clone)
      end
    end
  end
end
