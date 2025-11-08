module Aptible
  module Auth
    class ExternalAwsRole < Resource
      belongs_to :organization

      field :id
      field :external_aws_role_id
      field :aws_account_id
      field :role_type
      field :role_arn
      field :last_verified_at, type: Time
      field :created_at, type: Time
      field :updated_at, type: Time
    end
  end
end