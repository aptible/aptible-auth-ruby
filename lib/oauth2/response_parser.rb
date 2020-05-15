# rubocop:disable all
# NOTE: This code has been in oauth2 master since 2018 but is awaiting a 2.0 release of oauth2
OAuth2::Response.register_parser(:json, ['application/json', 'text/javascript', 'application/hal+json', 'application/vnd.collection+json', 'application/vnd.api+json']) do |body|
  MultiJson.load(body) rescue body # rubocop:disable RescueModifier
end