# frozen_string_literal: true

module Nylas
  module Model
    # Allows definition of attributes, which should transfer to other dependent attributes
    module Transferable
      def self.included(model)
        model.extend(ClassMethods)
        model.init_attribute_recipients
      end

      def initialize(**initial_data)
        assign(**initial_data)
        transfer_attributes
      end

      private def transfer_attributes
        self.class.attribute_recipients.each_pair do |name, recipient_names|
          value = send(:"#{name}")
          next if value.nil?
          recipient_names.each do |recipient_name|
            recipient = send(:"#{recipient_name}")
            transfer_to_recipient(name, value, recipient) unless recipient.nil?
          end
        end
      end

      private def transfer_to_recipient(name, value, recipient)
        if recipient.respond_to?(:each)
          recipient.each { |item| item.send(:"#{name}=", value) }
        else
          recipient.send(:"#{name}=", value)
        end
      end

      # Methods to call when tweaking Transferable classes
      module ClassMethods
        attr_accessor :attribute_recipients
        def init_attribute_recipients
          self.attribute_recipients ||= {}
        end

        def transfer(*attributes, **opts)
          attributes.each { |name| self.attribute_recipients[name] = opts[:to] }
        end
      end
    end
  end
end
