describe Nylas::ExpandedMessage do
  describe '.collection_name' do
    it 'equals to "messages"' do
      expect(Nylas::Message.collection_name).to eq('messages')
    end
  end
end
