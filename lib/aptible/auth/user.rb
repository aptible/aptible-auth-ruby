module Aptible
  module Auth
    class User < Resource
      has_many :roles
      has_many :ssh_keys
      has_many :whitelist_memberhips

      field :id
      field :name
      field :email
      field :username
      field :verified, type: Aptible::Resource::Boolean
      field :superuser, type: Aptible::Resource::Boolean
      field :created_at, type: Time
      field :updated_at, type: Time

      def organizations
        # Establish uniqueness of requests before loading all organizations
        # We can do this by reading the `organization` link for each role
        roles.map(&:links).map(&:organization).uniq(&:href).map(&:get)
      end

      def operations
        # TODO: Implement query params for /operations
        []
      end
    end
  end
end
