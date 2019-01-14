module Nylas
  class Tracking
    include Model::Attributable
    attribute :links, :boolean
    attribute :opens, :boolean
    attribute :thread_replies, :boolean
    attribute :payload, :string
  end
end
