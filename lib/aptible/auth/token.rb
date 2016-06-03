require 'oauth2'

module Aptible
  module Auth
    class Token < Resource
      # Unlike other resources, tokens aren't created in a REST fashion.
      # Instead, they're created via OAuth grants. This means we need to
      # override the way HyperResource / aptible-resource normally do things
      # and plug in an OAuth library.
      #
      # To do so, we take control of the creation arguments and feed them into
      # the OAuth2 library (in Token.create!), and then feed the response back
      # to HyperResource (in Token#apply_oauth_response).
      belongs_to :user
      belongs_to :actor

      field :access_token
      field :refresh_token
      field :expires_at

      def self.create!(options)
        token = new
        token.process_options(options)
        token
      rescue OAuth2::Error => e
        # Rethrow OAuth2::Error as HyperResource::ResponseError for
        # aptible-resource to handle
        raise HyperResource::ResponseError.new(e.code, response: e.response,
                                                       cause: e)
      end

      def authenticate_user(email, password, options = {})
        options[:scope] ||= 'manage'
        oauth_token = oauth.password.get_token(email, password, options)
        apply_oauth_response(oauth_token)
      end

      def authenticate_client(id, secret, subject, options = {})
        options[:scope] ||= 'manage'
        oauth_token = oauth.assertion.get_token({
          iss: id,
          sub: subject
        }.merge(signing_params_from_secret(secret).merge(options)))
        apply_oauth_response(oauth_token)
      end

      def authenticate_impersonate(subject_token, subject_token_type, options)
        # TODO: This duplicates aptible-resource, is it worth extracting?
        actor_token = \
          case actor_token = options.delete(:token)
          when Aptible::Resource::Base then actor_token.access_token
          when Fridge::AccessToken then actor_token.to_s
          when String then actor_token
          else bearer_token
          end

        # TODO: Do we want to check whether the token is non-nil at this stage?
        options[:scope] ||= 'manage'
        oauth_token = oauth.token_exchange.get_token(
          actor_token, 'urn:ietf:params:oauth:token-type:jwt',
          subject_token, subject_token_type, options)
        apply_oauth_response(oauth_token)
      end

      def oauth
        options = { site: root_url, token_url: '/tokens' }
        @oauth ||= OAuth2::Client.new(nil, nil, options)
      end

      def process_options(options)
        options = options.dup
        if (email = options.delete(:email)) &&
           (password = options.delete(:password))
          authenticate_user(email, password, options)
        elsif (client_id = options.delete(:client_id)) &&
              (client_secret = options.delete(:client_secret)) &&
              (subject = options.delete(:subject))
          authenticate_client(client_id, client_secret, subject, options)
        elsif (href = options.delete(:user_href))
          authenticate_impersonate(href, 'aptible:user:href', options)
        elsif (href = options.delete(:organization_href))
          authenticate_impersonate(href, 'aptible:organization:href', options)
        elsif (email = options.delete(:user_email))
          authenticate_impersonate(email, 'aptible:user:email', options)
        else
          fail 'Unrecognized options'
        end
      end

      def token
        # If the user set an arbitrary token, then we'll return that one,
        # otherwise we'll fall back to the Token itself, which makes it
        # possible to create a token and immediately access it #user or #actor
        # methods.
        # NOTE: Setting the token after the fact probably doesn't work anyway,
        # since the Authorization header won't be updated.
        @token || access_token
      end

      def expires_at
        # The Auth API returns the expiry as a timestamp (i.e. an Integer), but
        # our API client knows only to handle times as strings. This overrides
        # the field method for expires_at to return a Time despite the
        # underlying API field being an Integer.
        Time.at(attributes[:expires_at])
      end

      private

      def apply_oauth_response(oauth_token)
        # apply() + loaded is what HyperResource normally does after
        # deserializing a response back from the API. On top of that, we need
        # to set the Authorization header so that the token can be used to make
        # further API requests (e.g. accessing token#user or token#actor).
        adapter.apply(oauth_token.to_hash, self)
        self.loaded = true
        headers['Authorization'] = "Bearer #{bearer_token}"
        self
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
