require_relative 'hash_with_normalized_keys'

module Nylas
  # Tracks a given models internal state.
  # Implements Hash for reading/writing of state
  # Conforms to ActiveModel::Dirty for consumer familiarity and to ease
  # integration into Rails codebases.
  # @see http://api.rubyonrails.org/classes/ActiveModel/Dirty.html
  class ModelState
    attr_accessor :starting_data, :changed_attributes, :new_data

    # @params starting_data [Hash] Data at time of load
    def initialize(starting_data = {})
      self.starting_data = HashWithNormalizedKeys.new(starting_data)
      self.changed_attributes = HashWithNormalizedKeys.new({})
      self.new_data = HashWithNormalizedKeys.new({})
    end

    # Retrieves data for a given parameter
    def [](parameter_name)
      new_data.key?(parameter_name) ? new_data[parameter_name] : starting_data[parameter_name]
    end

    def []=(parameter_name, value)
      changed_attributes[parameter_name] = starting_data[parameter_name]
      new_data[parameter_name] = value
    end

    def clear_attribute_changes(*attributes)
      attributes.map do |attribute|
        changed_attributes.delete[attribute]
      end
    end

    def clear_changes_information
      self.changed_attributes = HashWithNormalizedKeys.new({})
    end

    def changes_applied
      self.previous_changes = changed_attributes
      self.starting_data = starting_data.merge(changed_attributes)
      clear_changes_information
    end

    def restore_attributes
      clear_changes_information
    end

    # @return [Hash] JSON hash of all changed data
    def as_json(options = {})
      new_data.keys.reduce({}) do |json, key|
        next json if options.fetch(:except, []).include?(key)
        value = new_data[key]
        json[key] = value.respond_to?(:as_json) ? value.as_json : value
        json
      end
    end
  end
end
