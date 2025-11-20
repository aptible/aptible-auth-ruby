module Aptible
  module Auth
    class ExternalAwsRole < Resource
      belongs_to :organization

      field :id
      field :external_aws_account_id
      field :aws_account_id
      field :role_type
      field :role_arn
      field :last_verified_at, type: Time
      field :created_at, type: Time
      field :updated_at, type: Time

      def external_aws_oidc_token!
        response = HyperResource::Link.new(
          self,
          'href' => "#{href}/external_aws_oidc_token"
        ).post(
          self.class.normalize_params(
            aws_account_id: attributes[:aws_account_id],
            role_arn: attributes[:role_arn],
            role_type: attributes[:role_type]
          )
        )
        ExternalAwsOidcToken.new(response.body)
      end
    end
  end
end
