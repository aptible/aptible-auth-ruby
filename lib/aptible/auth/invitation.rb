module Aptible
  module Auth
    class Invitation < Resource
      belongs_to :role

      field :id
      field :email
      field :created_at, type: Time
    end
  end
end
