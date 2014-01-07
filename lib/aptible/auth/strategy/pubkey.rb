require 'oauth2'

module Aptible
  module Auth
    module Strategy
      # The Pubkey Strategy (Aptible-custom)
      class Pubkey < OAuth2::Strategy::Base
        # TODO: Implement
        #
        # @raise [NotImplementedError]
        def get_token(fingerprint, params = {}, opts = {})
          # rubocop:disable UselessAssignment
          params = {
            'grant_type'  => 'pubkey',
            'fingerprint' => fingerprint,
            'password'    => password
          }.merge(client_params).merge(params)
          # rubocop:enable UselessAssignment

          fail NotImplementedError, 'Strategy not yet implemented'
        end
      end
    end
  end
end
