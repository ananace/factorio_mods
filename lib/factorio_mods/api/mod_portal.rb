require 'json'

module FactorioMods::Api
  ## Information taken from https://wiki.factorio.com/Mod_portal_API
  class ModPortal
    BASE_URL = 'https://mods.factorio.com'.freeze

    def all_mods(data = {})
      paginate = data.delete :paginate

      uri = URI(File.join(BASE_URL, 'api', 'mods'))
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

    def mod(name)
      uri = URI(File.join(BASE_URL, 'api', 'mods', name))
      FactorioMods::Mod.new JSON.parse(Net::HTTP.get(uri), symbolize_names: true)
    end

    def mods(*names)
      uri = URI(File.join(BASE_URL, 'api', 'mods'))
      uri.query = 'page_size=max&' + names.map { |mod| "namelist=#{mod}" }.join('&')
      JSON.parse(Net::HTTP.get(uri), symbolize_names: true)
          .fetch(:results)
          .map { |mod| FactorioMods::Mod.new mod }
    end

    def raw_mod(name)
      uri = URI(File.join(BASE_URL, 'api', 'mods', name))
      JSON.parse(Net::HTTP.get(uri), symbolize_names: true)
    end
  end
end
