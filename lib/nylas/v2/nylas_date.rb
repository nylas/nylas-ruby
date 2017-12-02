module Nylas
  module V2
    class NylasDate
      include Model::Attributable
      attribute :object, :string
      attribute :date, :date
    end

    class NylasDateType < Types::HashType
      casts_to NylasDate
    end

    Types.registry[:nylas_date] = NylasDateType.new
  end
end
