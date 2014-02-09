require 'hyperresource'

module Aptible
  module Auth
    class Client < HyperResource
      attr_accessor :token, :config

      def initialize(options = {})
        unless options.is_a?(Hash)
          fail ArgumentError, 'Call Aptible::Auth::Client.new with a Hash'
        end
        @token = options[:token]

        options[:root] ||= config.root_url
        options[:headers] ||= { 'Content-Type' => 'application/json' }
        options[:headers].merge!(
          'Authorization' => "Bearer #{options[:token].access_token}"
        ) if options[:token]

        super(options)
      end

      def config
        @config ||= Aptible::Auth.configuration
      end
    end
  end
end
