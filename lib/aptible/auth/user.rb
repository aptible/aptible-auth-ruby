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
      field :created_at, type: Time
      field :updated_at, type: Time

      # rubocop:disable MethodLength
      def set_organization_roles(organization, roles)
        self.roles.each do |role|
          next unless role.organization.id == organization.id
          next if roles.map(&:id).include? role.id

          role_membership = role.memberships.find do |membership|
            membership.user.id == id
          end

          role_membership.destroy
        end

        add_to_roles(roles)
      end
      # rubocop:enable MethodLength

      def organizations
        roles.map(&:organization).uniq(&:id)
      end

      def organization_roles(organization)
        roles.select do |role|
          role.links['organization'].href == organization.href
        end
      end

      def organization_privileged_roles(organization)
        privileged_roles.select do |role|
          role.links['organization'].href == organization.href
        end
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
      def is_billing_contact?(organization)
        organization.billing_contact_id && organization.billing_contact_id == id
      end

      def has_role?(role)
        roles.select { |user_role| role.id == user_role.id }.count > 0
      end
      # rubocop:enable PredicateName

      def can_manage?(organization)
        privileged_organizations.map(&:id).include? organization.id
      end

      def add_to_roles(roles)
        roles.each { |role| add_to_role(role) }
      end

      def add_to_role(role)
        role.create_membership(user: self, token: token) unless has_role? role
      end
    end
  end
end
