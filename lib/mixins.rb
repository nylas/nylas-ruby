module Nylas
  module ReadUnreadMethods
    def update_param!(param, value)
      update('PUT', '', {
        param => value,
      })
    end

    def mark_as_read!
      update_param!(:unread, false)
    end

    def mark_as_unread!
      update_param!(:unread, true)
    end

    def star!
      update_param!(:starred, true)
    end

    def unstar!
      update_param!(:starred, false)
    end
  end
end

