module Aptible
  class Auth::Session < Auth::Resource
    belongs_to :user
  end
end
