require 'active_support/inflector'

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
      resource.send(basename).entries
    end

    def self.find(id, options = {})
      find_by_url("#{collection_url}/#{id}", options)
    end

    def self.find_by_url(url, options = {})
      # REVIEW: Should exception be raised if return type mismatch?
      new(options).find_by_url(url)
    rescue
      nil
    end

    def self.create(options)
      token = options.delete(:token)
      auth = Auth.new(token: token)
      auth.send(basename).create(options)
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
      define_method "create_#{relation.to_s.singularize}" do |options = {}|
        get unless loaded
        links[relation].create(options)
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
