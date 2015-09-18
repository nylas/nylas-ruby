require 'delta_filters'

describe Inbox::DeltaFilters do
  describe 'building exclude_types filter' do
    subject(:delta_filters) { described_class.new }

    it 'maps the object type to filter parameter, joining them with a comma' do
      types = Inbox::API::OBJECTS_TABLE.values
      parameters = Inbox::API::OBJECTS_TABLE.keys

      exclude_filter = delta_filters.build_exclude_types(types)
      expect(exclude_filter).to eq("&exclude_types=#{parameters.join(',')}")
    end

    it 'skips unknown object types' do
      UnknownType = Class.new
      types = [Inbox::Account, UnknownType, Inbox::Tag ]
      exclude_filter = delta_filters.build_exclude_types(types)
      expect(exclude_filter).to eq('&exclude_types=account,tag')
    end

    it 'is empty when no exclude types are specified' do
      exclude_filter = delta_filters.build_exclude_types([])
      expect(exclude_filter).to be_empty
    end

    it 'accepts a single object type' do
      types = Inbox::Message
      exclude_filter = delta_filters.build_exclude_types(types)
      expect(exclude_filter).to eq('&exclude_types=message')
    end
  end
end
