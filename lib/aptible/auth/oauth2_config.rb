require 'oauth2'

OAuth2::Response.register_parser(:json, ['application/json', 'text/javascript', 'application/hal+json']) do |body|
  MultiJson.load(body) rescue body
end
