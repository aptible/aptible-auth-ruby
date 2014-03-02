require 'gem_config'
require 'hyperresource'
require 'fridge'

module Aptible
  class Auth < HyperResource
    include GemConfig::Base

    attr_accessor :token, :config

    with_configuration do
      has :root_url,
          classes: [String],
          default: ENV['APTIBLE_AUTH_ROOT_URL'] || 'https://auth.aptible.com'
    end

    def self.public_key
      Resource.new.get.public_key
    end

    def initialize(options = {})
      self.token = options[:token]

      options[:root] ||= config.root_url
      options[:headers] ||= { 'Content-Type' => 'application/json' }
      options[:headers].merge!(
        'Authorization' => "Bearer #{bearer_token}"
      ) if options[:token]

      super(options)
    end

    def bearer_token
      case token
      when Aptible::Auth::Token then token.access_token
      when Fridge::AccessToken then token.to_s
      when String then token
      end
    end

    def config
      @config ||= Aptible::Auth.configuration
    end
  end
end

require 'aptible/auth/resource'
require 'aptible/auth/token'
require 'aptible/auth/user'
