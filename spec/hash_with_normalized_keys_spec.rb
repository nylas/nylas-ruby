require 'spec_helper'
require 'nylas/hash_with_normalized_keys'


describe Nylas::HashWithNormalizedKeys do
  it "casts keys to symbols by default" do
    normalized_hash = described_class.new({ "a string key" => "value of string key",
                                            nil => "value of nil key",
                                            1 => "value of number key",
                                            [] => "value of an array key",
                                            [:an, :array, :with, :contents] => "value of another array",
                                            {} => "value of a hash key",
                                            { another_hash: :key } => "value of another hash key" })

    expect(normalized_hash["a string key"]).to eq "value of string key"
    expect(normalized_hash[nil]).to eq "value of nil key"
    expect(normalized_hash[1]).to eq "value of number key"
    expect(normalized_hash[[]]).to eq "value of an array key"
    expect(normalized_hash[[:an, :array, :with, :contents]]).to eq "value of another array"
    expect(normalized_hash[{}]).to eq "value of a hash key"
    expect(normalized_hash[{ another_hash: :key }]).to eq "value of another hash key"
  end

  it "allows you to set the casting method for those who would prefer object identity for their keys" do
    first_array = [:an_array]
    second_array = first_array.dup
    expect(first_array.object_id).to_not eq second_array.object_id

    normalized_hash = described_class.new({}, normalize_keys_with: ->(key) { key.object_id })

    normalized_hash[first_array] = "the first array"
    normalized_hash[second_array] = "the second, unique array"

    expect(normalized_hash[first_array]).to eql "the first array"
    expect(normalized_hash[second_array]).to eql "the second, unique array"
  end
end

