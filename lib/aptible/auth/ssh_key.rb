module Aptible
  module Auth
    class SshKey < Resource
      belongs_to :user

      field :id
      field :name
      field :public_key_fingerprint
      field :ssh_public_key
      field :created_at, type: Time
      field :updated_at, type: Time
    end
  end
end
