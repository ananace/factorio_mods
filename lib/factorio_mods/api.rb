require 'net/http'

module FactorioMods
  module Api
    autoload :Download, 'factorio_mods/api/download'
    autoload :Matchmaking, 'factorio_mods/api/matchmaking'
    autoload :ModPortal, 'factorio_mods/api/mod_portal'
    autoload :WebAuthentication, 'factorio_mods/api/web_authentication'
  end
end
