require 'pry'

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
      def set_org_role_memberships(organization, role_ids)
        roles.each do |role|
          if role.organization.id == organization.id
            unless role_ids.include? role.id
              # rubocop:disable CollectionMethods
              role_membership = role.memberships.detect do |membership|
                membership.user.id == id
              end
              # rubocop:enable CollectionMethods

              role_membership.destroy
            end
          end
        end

        create_role_memberships_by_role_id(role_ids)
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

      def create_role_memberships_by_role_id(role_ids)
        role_ids.each do |role_id|
          role = Aptible::Auth::Role.find(role_id, token: token)

          unless has_role? role
            role.create_membership(user: self, token: token)
          end
        end
      end
    end
  end
end
