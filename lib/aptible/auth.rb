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
      Agent.new.public_key
    end
  end
end

require 'aptible/auth/resource'
require 'aptible/auth/agent'
