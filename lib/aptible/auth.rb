require 'aptible/auth/version'
require 'aptible/auth/token'
require 'aptible/auth/client'

require 'gem_config'

module Aptible
  module Auth
    include GemConfig::Base

    with_configuration do
      has :root_url,
          classes: [String],
          default: ENV['APTIBLE_AUTH_ROOT_URL'] || 'https://auth.aptible.com'
    end

    def self.public_key
      Client.new.get.public_key
    end
  end
end
