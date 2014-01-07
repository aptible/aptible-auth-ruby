require 'oauth2'
require 'aptible/auth/strategy/pubkey'

module Aptible
  module Auth
    class Client < OAuth2::Client
      # The Pubkey Strategy (Aptible-custom)
      def pubkey
        @pubkey ||= Aptible::Auth::Strategy::Pubkey.new(self)
      end
    end
  end
end
