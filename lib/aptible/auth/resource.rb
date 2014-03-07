module Aptible
  class Auth::Resource < Auth
    def self.find_by_url(url)
      # REVIEW: Should exception be raised if return type mismatch?
      new.find_by_url(url)
    end
  end
end

require 'aptible/auth/client'
require 'aptible/auth/membership'
require 'aptible/auth/organization'
require 'aptible/auth/role'
require 'aptible/auth/session'
require 'aptible/auth/token'
require 'aptible/auth/user'
