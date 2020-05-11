# rubocop:disable all
module OAuth2
  module Strategy
    # The Token Exchange strategy
    #
    # @see https://tools.ietf.org/html/draft-ietf-oauth-token-exchange-03#section-4.1
    class TokenExchange < Base
      GRANT_TYPE = 'urn:ietf:params:oauth:grant-type:token-exchange'

      # Not used for this strategy
      #
      # @raise [NotImplementedError]
      def authorize_url
        fail(NotImplementedError, 'The authorization endpoint is not used in this strategy')
      end

      # Retrieve an access token given the specified End User username and password.
      #
      # @param [String] username the End User username
      # @param [String] password the End User password
      # @param [Hash] params additional params
      def get_token(actor_token, actor_token_type, subject_token, subject_token_type, params = {}, opts = {})
        params = {'grant_type'          => GRANT_TYPE,
                  'actor_token'         => actor_token,
                  'actor_token_type'    => actor_token_type,
                  'subject_token'       => subject_token,
                  'subject_token_type'  => subject_token_type
        }.merge(client_params).merge(params)
        @client.get_token(params, opts)
      end
    end
  end

  # Add strategy to OAuth2::Client
  class Client
    def token_exchange
      @token_exchange ||= OAuth2::Strategy::TokenExchange.new(self)
    end
  end
end
