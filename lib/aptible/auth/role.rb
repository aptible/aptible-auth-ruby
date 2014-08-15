module Aptible
  module Auth
    class Role < Resource
      belongs_to :organization
      has_many :memberships
      has_many :invitations

      field :id
      field :name
      field :privileged, type: Aptible::Resource::Boolean
      field :created_at, type: Time
      field :updated_at, type: Time

      def users
        @users ||= memberships.map(&:user).uniq
      end

      def set_account_permissions(account, scopes)
        account_permissions = account_permissions(account)
        existing_permissions = account_permissions.select do |permission|
          permission.destroy unless scopes.include? permission.scope
          return scopes.include? permission.scope
        end

        new_scopes = scopes - existing_permissions.map(&:scope)
        add_account_scopes(account, new_scopes)
      end

      def account_permissions(account)
        account.permissions.select do |permission|
          (link = permission.links[:role]) && link.href == href
        end
      end

      def add_account_scopes(account, scopes)
        scopes.each { |scope| add_account_scope(account, scope) }
      end

      def add_account_scope(account, scope)
        account.create_permission!({ scope: scope, role: href })
      end

      def permissions
        require 'aptible/api'

        permissions = Aptible::Api::Permission.all(token: token,
                                                    headers: headers)
        permissions.select do |permission|
          (link = permission.links[:role]) && link.href == href
        end
      end
    end
  end
end
