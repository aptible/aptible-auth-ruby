module Aptible
  module Auth
    class User < Resource
      has_many :roles
      has_many :ssh_keys

      field :id
      field :name
      field :email
      field :username
      field :verified, type: Aptible::Resource::Boolean
      field :superuser, type: Aptible::Resource::Boolean
      field :created_at, type: Time
      field :updated_at, type: Time

      def organizations
        roles.map(&:organization).uniq(&:id)
      end

      def operations
        # TODO: Implement query params for /operations
        []
      end
    end
  end
end
