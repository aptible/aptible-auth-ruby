module Aptible
  class Auth::Membership < Auth::Resource
    belongs_to :role
    belongs_to :user
  end
end
