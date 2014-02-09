require 'oauth2'

module Aptible
  module Auth
    class Token
      attr_accessor :client, :access_token, :refresh_token, :expires_at

      def initialize(options = {})
        oauth_params = {
          site: Aptible::Auth.configuration.root_url,
          token_url: '/tokens'
        }
        @client = OAuth2::Client.new(nil, nil, oauth_params)

        process_options(options)
      end

      def authenticate_user(email, password, options = {})
        options[:scope] ||= 'manage'
        response = client.password.get_token(email, password, options)
        parse_oauth_response(response)
      end

      def authenticate_client(id, secret, user, options = {})
        options[:scope] ||= 'manage'
        response = client.assertion.get_token(id, secret, user, options)
        parse_oauth_response(response)
      end

      private

      def process_options(options)
        if (email = options.delete(:email)) &&
           (password = options.delete(:password))
          authenticate_user(email, password, options)
        elsif (client_id = options.delete(:client_id)) &&
              (client_secret = options.delete(:client_secret)) &&
              (user = options.delete(:user))
          authenticate_client(client_id, client_secret, user, options)
        end
      end

      def parse_oauth_response(response)
        @access_token = response.token
        @refresh_token = response.refresh_token
        @expires_at = Time.at(response.expires_at)
      end
    end
  end
end
