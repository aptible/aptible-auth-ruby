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

    def self.get_data_type_from_response(response)
      return nil unless response && response.body
      adapter.get_data_type_from_object(adapter.deserialize(response.body))
    end

    def self.adapter
      Aptible::Auth::Adapter
    end

    def adapter
      self.class.adapter
    end

    def initialize(options = {})
      if options.is_a?(Hash)
        self.token = options[:token]

        options[:root] ||= config.root_url
        options[:namespace] ||= 'Aptible::Auth'
        options[:headers] ||= { 'Content-Type' => 'application/json' }
        options[:headers].merge!(
          'Authorization' => "Bearer #{bearer_token}"
        ) if options[:token]
      end

      super(options)
    end

    def find_by_url(url)
      fail "URL must be rooted at #{root}" unless /^#{root}/.match url

      resource = dup
      resource.href = url.gsub(/^#{root}/, '')
      resource.get
    end

    def organizations
      orgs
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

require 'aptible/auth/adapter'
require 'aptible/auth/resource'
