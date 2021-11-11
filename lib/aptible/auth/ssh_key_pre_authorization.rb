module Aptible
  module Auth
    class SshKeyPreAuthorization < Resource
      belongs_to :ssh_key
      belongs_to :owner

      field :created_at, type: Time
      field :updated_at, type: Time
    end
  end
end
