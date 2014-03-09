module Aptible
  class Auth::Organization < Auth::Resource
    has_many :roles

    def accounts
      api = Aptible::Api.new(token: token, headers: headers)
      api.get unless api.loaded
      accounts = api.accounts.entries
      accounts.select { |account| account.organization.href == href }
    end
  end
end
