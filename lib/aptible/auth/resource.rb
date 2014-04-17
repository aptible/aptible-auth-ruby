require 'active_support/inflector'

# rubocop:disable ClassAndModuleChildren
module Aptible
  class Auth::Resource < Auth
    def self.basename
      name.split('::').last.downcase.pluralize
    end

    def self.collection_url
      config = Aptible::Auth.configuration
      config.root_url.chomp('/') + "/#{basename}"
    end

    def self.all(options = {})
      resource = find_by_url(collection_url, options)
      return [] unless resource
      resource.send(basename).entries
    end

    def self.find(id, options = {})
      find_by_url("#{collection_url}/#{id}", options)
    end

    def self.find_by_url(url, options = {})
      # REVIEW: Should exception be raised if return type mismatch?
      new(options).find_by_url(url)
    rescue HyperResource::ClientError => e
      if e.response.status == 404
        return nil
      else
        raise e
      end
    end

    def self.create(params)
      token = params.delete(:token)
      auth = Auth.new(token: token)
      auth.send(basename).create(normalize_params(params))
    end

    # rubocop:disable PredicateName
    def self.has_many(relation)
      define_has_many_getter(relation)
      define_has_many_setter(relation)
    end
    # rubocop:enable PredicateName

    def self.belongs_to(relation)
      define_method relation do
        get unless loaded
        if (memoized = instance_variable_get("@#{relation}"))
          memoized
        else
          instance_variable_set("@#{relation}", links[relation].get)
        end
      end
    end

    def self.normalize_params(params = {})
      params_array = params.map do |key, value|
        value.is_a?(HyperResource) ? [key, value.href] : [key, value]
      end
      Hash[params_array]
    end

    def update(params = {})
      super(self.class.normalize_params(params))
    end

    # NOTE: The following does not update the object in-place
    def reload
      self.class.find_by_url(href, headers: headers)
    end

    private

    def self.define_has_many_getter(relation)
      define_method relation do
        get unless loaded
        if (memoized = instance_variable_get("@#{relation}"))
          memoized
        elsif links[relation]
          instance_variable_set("@#{relation}", links[relation].entries)
        end
      end
    end

    def self.define_has_many_setter(relation)
      define_method "create_#{relation.to_s.singularize}" do |params = {}|
        get unless loaded
        links[relation].create(self.class.normalize_params(params))
      end
    end
  end
end

require 'aptible/auth/client'
require 'aptible/auth/membership'
require 'aptible/auth/organization'
require 'aptible/auth/role'
require 'aptible/auth/session'
require 'aptible/auth/token'
require 'aptible/auth/user'
