require 'oauth2'

module Aptible
  class Auth::Token < Auth::Resource
    attr_accessor :access_token, :refresh_token, :expires_at

    def self.create(options)
      token = new
      token.process_options(options)
      token
    end

    def authenticate_user(email, password, options = {})
      options[:scope] ||= 'manage'
      response = oauth.password.get_token(email, password, options)
      parse_oauth_response(response)
    end

    def authenticate_client(id, secret, subject, options = {})
      options[:scope] ||= 'manage'
      response = oauth.assertion.get_token({
        iss: id,
        sub: subject
      }.merge(signing_params_from_secret(secret).merge(options)))
      parse_oauth_response(response)
    end

    def oauth
      options = { site: config.root_url, token_url: '/tokens' }
      @oauth ||= OAuth2::Client.new(nil, nil, options)
    end

    def process_options(options)
      if (email = options.delete(:email)) &&
         (password = options.delete(:password))
        authenticate_user(email, password, options)
      elsif (client_id = options.delete(:client_id)) &&
            (client_secret = options.delete(:client_secret)) &&
            (subject = options.delete(:subject))
        authenticate_client(client_id, client_secret, subject, options)
      end
    end

    private

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
