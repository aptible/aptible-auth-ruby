# rubocop:disable ClassAndModuleChildren
module Aptible
  class Auth::Organization < Auth::Resource
    has_many :roles

    def security_officer
      # REVIEW: Examine underlying data model for a less arbitrary solution
      security_officers_role = roles.find do |role|
        role.name == 'Security Officers'
      end
      security_officers_role.users.first if security_officers_role
    end

    def accounts
      api = Aptible::Api.new(token: token, headers: headers)
      api.get unless api.loaded
      accounts = api.accounts.entries
      accounts.select { |account| account.organization.href == href }
    end
  end
end
