module Aptible
  module Auth
    class Session < Resource
      belongs_to :user

      field :id
      field :verified, type: Aptible::Resource::Boolean
      field :created_at, type: Time
      field :updated_at, type: Time
    end
  end
end
