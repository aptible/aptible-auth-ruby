module Aptible
  module Auth
    class Membership < Resource
      belongs_to :role
      belongs_to :user

      field :id
      field :created_at, type: Time
    end
  end
end
