module Aptible
  class Auth::Role < Auth::Resource
    belongs_to :organization

    def privileged?
      !!attributes['privileged']
    end
  end
end
