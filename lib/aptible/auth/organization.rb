module Aptible
  module Auth
    class Organization < Resource
      has_many :roles

      def security_officer
        # REVIEW: Examine underlying data model for a less arbitrary solution
        security_officers_role = roles.find do |role|
          role.name == 'Security Officers'
        end
        security_officers_role.users.first if security_officers_role
      end

      def accounts
        require 'aptible/api'

        accounts = Aptible::Api::Account.all(token: token, headers: headers)
        accounts.select { |account| account.organization.href == href }
      end
    end
  end
end
