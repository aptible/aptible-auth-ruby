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
        response = client.assertion.get_token({
          iss: id,
          sub: user
        }.merge(signing_params_from_secret(secret).merge(options)))
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

      def signing_params_from_secret(secret)
        private_key = parse_private_key(secret)
        {
          private_key: private_key,
          algorithm:  "RS#{key_length(private_key) / 2}"
        }
      end

      def parse_private_key(string)
        if string =~ /\A-----/
          OpenSSL::PKey::RSA.new(string)
        else
          formatted_string = <<-PRIVATE_KEY.gsub(/^\s+/, '')
            -----BEGIN RSA PRIVATE KEY-----
            #{string.scan(/.{1,64}/).join("\n")}
            -----END RSA PRIVATE KEY-----
          PRIVATE_KEY
          OpenSSL::PKey::RSA.new(formatted_string)
        end
      end

      def key_length(private_key)
        # http://stackoverflow.com/questions/13747212
        private_key.n.num_bytes * 8
      end
    end
  end
end
