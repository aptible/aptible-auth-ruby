module Aptible
  module Auth
    class Client < Resource
      belongs_to :user

      field :id
      field :name
      field :client_id
      field :privileged, type: Aptible::Resource::Boolean
      field :created_at, type: Time
      field :updated_at, type: Time
    end
  end
end
