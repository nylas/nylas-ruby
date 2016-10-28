require 'restful_model'

module Nylas
  class File < RestfulModel

    parameter :size
    parameter :filename
    parameter :content_id
    parameter :content_type
    parameter :is_embedded
    parameter :message_id

    # For uploading the file
    parameter :file

    def inflate(json)
      super
      content_type = json["content-type"] if json["content-type"]
    end

    def save!
      ::RestClient.post(url, {:file => @file}) do |response, request, result|
        json = Nylas.interpret_response(result, response, :expected_class => Object)
        json = json[0] if (json.class == Array)
        inflate(json)
      end
      self
    end

    def download
      download_url = self.url('download')
      ::RestClient.get(download_url) do |response, request, result|
        Nylas.interpret_response(result, response, {:raw_response => true})
        response
      end
    end

  end
end

