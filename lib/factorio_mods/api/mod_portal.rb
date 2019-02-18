require 'cgi'
require 'erb'
require 'json'

module FactorioMods::Api
  ## Information taken from https://wiki.factorio.com/Mod_portal_API
  class ModPortal
    BASE_URL = 'https://mods.factorio.com'.freeze

    def self.all_mods(data = {})
      paginate = data.delete :paginate

      uri = URI(BASE_URL + '/api/mods')
      uri.query = data.map { |k, v| "#{k}=#{v}" }.join '&'

      data = JSON.parse(Net::HTTP.get(uri), symbolize_names: true)
      puts data
      results = data.fetch(:results).map { |mod| FactorioMods::Mod.new mod }
      while paginate && data[:pagination][:links][:next]
        uri = URI(data[:pagination][:links][:next])
        data = JSON.parse(Net::HTTP.get(uri), symbolize_names: true)
        results.concat(data.fetch(:results).map { |mod| FactorioMods::Mod.new mod })
      end

      results
    end

    def self.mod(name)
      FactorioMods::Mod.new raw_mod(name)
    end

    def self.mods(*names)
      uri = URI(BASE_URL + '/api/mods')
      uri.query = 'page_size=max&' + names.map { |mod| "namelist=#{CGI.escape mod}" }.join('&')
      JSON.parse(Net::HTTP.get(uri), symbolize_names: true)
          .fetch(:results)
          .map { |mod| FactorioMods::Mod.new mod }
    end

    def self.raw_mod(name)
      uri = URI(BASE_URL + '/api/mods/' + ERB::Util.url_encode(name))
      JSON.parse(Net::HTTP.get(uri), symbolize_names: true)
    end
  end
end
