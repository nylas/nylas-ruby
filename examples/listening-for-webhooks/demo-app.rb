require 'sinatra'
require 'nylas'

get '/webhook-event-received' do
  params[:challenge]
end

post '/webhook-event-received' do
  request.body.rewind
  json = request.body.read
  logger.info ["json", json]
  data = JSON.parse(json, symbolize_names: true)
  deltas = Nylas::Deltas.new(**data)
  deltas.map do |delta|
    logger.info ["delta", delta.to_h]
    logger.info ["instance", delta.instance.class, delta.instance.to_h]
  end
  params[:challenge]
end
