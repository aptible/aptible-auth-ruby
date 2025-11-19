module Aptible
  module Auth
    class Organization < Resource
      has_many :roles
      has_many :users
      has_many :invitations
      has_many :whitelist_memberships
      has_many :external_aws_roles
      belongs_to :security_officer

      field :id
      field :name
      field :handle
      field :created_at, type: Time
      field :updated_at, type: Time
      field :primary_phone
      field :emergency_phone
      field :city
      field :state
      field :zip
      field :address
      field :security_alert_email
      field :ops_alert_email
      field :security_officer_id
      field :enterprise
      field :sso_enforced

      def privileged_roles
        roles.select(&:privileged?)
      end

      def accounts
        return @accounts if @accounts

        require 'aptible/api'

        accounts = Aptible::Api::Account.all(token: token, headers: headers)
        @accounts = accounts.select do |account|
          (link = account.links[:organization]) && link.href == href
        end
      end

      # SamlConfiguration is a dependent object that does not
      # have a link until created. So, we create the link for it
      # to allow HyperResource to successfully create the object.
      # Afterwords, we can directly manage the SamlConfiguration
      def create_saml_configuration!(params)
        HyperResource::Link.new(
          self,
          'href' => "#{href}/saml_configurations"
        ).post(self.class.normalize_params(params))
      end

      def create_external_aws_role!(params)
        HyperResource::Link.new(
          self,
          'href' => "#{href}/external_aws_roles"
        ).post(self.class.normalize_params(params))
      end

      def find_external_aws_role(aws_account_id:, role_type:)
        link = HyperResource::Link.new(
          self,
          'href' => "#{href}/external_aws_roles"
        )
        response = link.get(params: {
          aws_account_id: aws_account_id,
          role_type: role_type
        })

        # Parse the response to get the embedded external_aws_roles
        roles = response.body.dig('_embedded', 'external_aws_roles') || []
        return nil if roles.empty?

        # Return the first matching role as an ExternalAwsRole object
        role_data = roles.first
        ExternalAwsRole.new(role_data.merge(
          adapter: adapter,
          loaded: true
        ))
      end
    end
  end
end
