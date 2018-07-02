module FactorioMods::Api
  ## Information taken from https://wiki.factorio.com/Web_authentication_API
  class WebAuthentication
    BASE_URL = 'https://auth.factorio.com'.freeze
    API_VERSION = 2

    class << self
      attr_accessor :username, :token
    end

    def self.login(username, password, version = API_VERSION, ownership = false)
      resp = Net::HTTP.post_form(URI(BASE_URL + '/api-login'),
                                 username: username,
                                 password: password,
                                 api_version: version,
                                 require_game_ownership: ownership.to_s)
      resp.value
      data = JSON.parse(resp.body, symbolize_names: true)

      @username = data[:username]
      @token = data[:token]
    end
  end
end
