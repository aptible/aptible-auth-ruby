module Aptible
  class Auth::User < Auth::Resource
    def verified?
      !!attributes['verified']
    end
  end
end
