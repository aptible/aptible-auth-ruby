module Aptible
  module Auth
    class SamlConfiguration < Resource
      belongs_to :organization

      field :id
      field :entity_id
      field :sign_in_url
      field :name_format
      field :certificate
      field :handle
      field :created_at, type: Time
      field :updated_at, type: Time
    end
  end
end
