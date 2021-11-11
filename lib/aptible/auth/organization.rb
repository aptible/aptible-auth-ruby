module Aptible
  module Auth
    class Organization < Resource
      has_many :roles
      has_many :users
      has_many :invitations
      has_many :whitelist_memberships
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
    end
  end
end
