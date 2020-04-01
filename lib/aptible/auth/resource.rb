require 'aptible/resource'

module Aptible
  module Auth
    class Resource < Aptible::Resource::Base
      def namespace
        'Aptible::Auth'
      end

      def root_url
        Aptible::Auth.configuration.root_url
      end
    end
  end
end

require 'aptible/auth/client'
require 'aptible/auth/invitation'
require 'aptible/auth/membership'
require 'aptible/auth/organization'
require 'aptible/auth/role'
require 'aptible/auth/session'
require 'aptible/auth/token'
require 'aptible/auth/user'
require 'aptible/auth/ssh_key'
require 'aptible/auth/saml_configuration'
require 'aptible/auth/whitelist_membership'
