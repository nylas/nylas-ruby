require 'nylas'
describe Nylas::V1::ExpandedMessage do
  include Nylas::V1

  describe '.collection_name' do
    it 'equals to "messages"' do
      expect(Message.collection_name).to eq('messages')
    end
  end
end
