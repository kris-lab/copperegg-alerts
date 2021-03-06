require 'singleton'
require 'httparty'
require 'deep_merge'

module Copperegg
  class Client
    include Singleton

    attr_reader :api_base_uri

    def initialize
      @api_base_uri = 'https://api.copperegg.com/v2/'
    end

    def auth_setup(api_key)
      @auth = {:basic_auth => {:username => api_key, :password => 'U'}}
      return self
    end

    def get(resource, *args)
      HTTParty.get(@api_base_uri + resource, @auth.to_hash)
    end

    JSON = {'content-type' => 'application/json'}

    def method_missing(method, resource, *args)
      if method.to_s =~ /\?$/
        method = method.to_s.sub!(/\?$/, '')
        result = self.send(method.to_sym, resource, *args)
        return result if result.code == 200
      end
    end

    ['post', 'put'].each do |method|
      define_method(method) do |resource, *args|
        body = {}
        args.each { |arg| body.deep_merge!(arg) }
        HTTParty.send(method.to_sym, @api_base_uri + resource, @auth.merge({:headers => JSON}.merge({:body => body.to_json})))
      end
    end

    def delete(resource, *args)
      HTTParty.delete(@api_base_uri + resource, @auth.to_hash)
    end

  end
end

