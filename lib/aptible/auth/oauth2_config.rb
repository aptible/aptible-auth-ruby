require 'oauth2'

json_mime_types = [
  'application/json',
  'text/javascript',
  'application/hal+json'
]

OAuth2::Response.register_parser(:json, json_mime_types) do |body|
  MultiJson.load(body) rescue body # rubocop:disable RescueModifier
end
