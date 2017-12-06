require 'simplecov'
SimpleCov.start


require 'nylas-streaming'
require 'webmock/rspec'

class FakeAPI
  def execute(method:, path:, payload: nil)
    requests.push({ method: method, path: path, payload: payload })
  end

  def requests
    @requests ||= []
  end
end
