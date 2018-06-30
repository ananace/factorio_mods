require 'nokogiri'

module FactorioMods::Api
  # Based on information from https://wiki.factorio.com/Download_API
  class Download
    BASE_URL = 'https://www.factorio.com'.freeze

    Version = Struct.new(:api, :version, :build, :distro) do
      def download(target)
        api.download_to(version, target, build, distro)
      end
    end

    def login(username_or_email, password)
      uri = URI(BASE_URL + '/login')
      http = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true)

      req = Net::HTTP::Get.new uri
      res = http.request(req)

      csrf_token = Nokogiri::HTML(res.body)
                           .at_xpath('//input[@name="csrf_token"]/@value')
                           .value

      cookie = res['set-cookie'].split('; ').first

      req = Net::HTTP::Post.new uri
      req.form_data = {
        csrf_token: csrf_token,
        username_or_email: username_or_email,
        password: password
      }
      req['cookie'] = cookie

      res = http.request(req)
      raise 'Login failed' unless res.is_a?(Net::HTTPOK) || res.is_a?(Net::HTTPFound)

      @session = res['set-cookie'].split('; ').first

      true
    ensure
      http.finish if http
    end

    def download(version, build = :alpha, distro = nil)
      raise 'Needs to be logged in' unless @session

      distro ||= if FactorioMods::OS.windows?
                   'win64-manual'
                 elsif FactorioMods::OS.linux?
                   'linux64'
                 elsif FactorioMods::OS.mac?
                   'osx'
                 end

      raise 'Unknown build' unless %i[alpha demo headless].include? build
      raise 'No distro specifed' unless distro

      uri = URI(BASE_URL + "/get-download/#{version}/#{build}/#{distro}")
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Get.new uri
        req['cookie'] = @session
        res = http.request(req)

        if res.is_a? Net::HTTPFound
          req = Net::HTTP::Get.new URI(res['location'])
          req['referer'] = BASE_URL + '/download'
          req['user-agent'] = 'Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0'
          res = Net::HTTP.start(req.uri.hostname, req.uri.port, use_ssl: true) do |http2|
            http2.request(req)
          end
        end
      end

      res.value
      res
    end

    def download_to(version, target = nil, build = :alpha, distro = nil)
      dir = ''
      if Dir.exist? target
        dir = File.join target, ''
        target = nil
      end

      data = download(version, build, distro) unless target
      target ||= data['content-disposition'].split('=').last.strip
      File.open(dir + target, 'wb') do |file|
        data ||= download(version, build, distro)
        file.write(data.body)
      end

      dir + target
    end

    def available_versions(build = :stable)
      raise 'Needs to be logged in' unless @session
      endpoints = {
        stable: '/download',
        experimental: '/download/experimental',
        headless: '/download-headless'
      }
      raise 'Unknown build' unless endpoints.key? build

      uri = URI(BASE_URL + endpoints[build])
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Get.new uri
        req['cookie'] = @session
        http.request(req)
      end

      doc = Nokogiri::HTML(res.body)

      doc.xpath('//body/div/ul//a/@href').map do |href|
        uri = URI(BASE_URL + href.value)
        components = uri.path.split('/').reject(&:empty?)

        Version.new(
          self,
          components[1],
          components[2].to_sym,
          components[3],
          uri
        )
      end
    end
  end
end
