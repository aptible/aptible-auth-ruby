module Aptible
  module Auth
    class WhitelistMembership < Resource
      belongs_to :organization
      embeds_one :user

      field :id
      field :created_at, type: Time
    end
  end
end
