require 'stripe'
require 'aptible/billing'

module Aptible
  module Auth
    class Organization < Resource
      has_many :roles
      has_many :users
      has_many :invitations
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

      def billing_detail
        @billing_detail ||= Aptible::Billing::BillingDetail.find(
          id, token: token, headers: headers
        )
      end

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
    end
  end
end
