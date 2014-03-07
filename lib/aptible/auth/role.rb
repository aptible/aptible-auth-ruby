module Aptible
  class Auth::Role < Auth::Resource
    def privileged?
      !!attributes['privileged']
    end
  end
end
