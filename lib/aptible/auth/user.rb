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

      # Returns roles with their organizations pre-loaded to avoid N+1 API calls
      # when iterating through roles and accessing role.organization.
      # Makes 2 backend requests: one for orgs, one for roles.
      def roles_with_organizations
        orgs_by_href = Organization.all(token: token, headers: headers)
                                   .index_by(&:href)

        roles.tap do |all_roles|
          all_roles.each do |role|
            org = orgs_by_href[role.links[:organization].href]
            role.instance_variable_set(:@organization, org)
          end
        end
      end
    end
  end
end
