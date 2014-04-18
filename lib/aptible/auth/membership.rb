module Aptible
  module Auth
    class Membership < Resource
      belongs_to :role
      belongs_to :user
    end
  end
end
