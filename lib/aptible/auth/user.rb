module Aptible
  module Auth
    class User < Resource
      has_many :roles

      field :id
      field :name
      field :email
      field :username
      field :verified, type: Aptible::Resource::Boolean
      field :public_key_fingerprint
      field :created_at, type: Time
      field :updated_at, type: Time

      # rubocop:disable MethodLength
      def set_organization_roles(organization, roles)
        self.roles.each do |role|
          if role.organization.id == organization.id
            unless roles.map(&:id).include? role.id
              role_membership = role.memberships.find do |membership|
                membership.user.id == id
              end

              role_membership.destroy
            end
          end
        end

        add_to_roles(roles)
      end
      # rubocop:enable MethodLength

      def organizations
        roles.map(&:organization).uniq(&:id)
      end

      def operations
        # TODO: Implement query params for /operations
        []
      end

      def privileged_organizations
        privileged_roles.map(&:organization)
      end

      def privileged_roles
        @privileged_roles ||= roles.select(&:privileged?)
      end

      # rubocop:disable PredicateName
      def has_role?(role)
        roles.select { |user_role| role.id == user_role.id }.count > 0
      end
      # rubocop:enable PredicateName

      def add_to_roles(roles)
        roles.each { |role| add_to_role(role) }
      end

      def add_to_role(role)
        role.create_membership(user: self, token: token) unless has_role? role
      end
    end
  end
end
