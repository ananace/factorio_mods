require 'time'

module FactorioMods
  class Mod
    class MediaFile
      MediaUrl = Struct.new(:original, :thumb)
      attr_accessor :id, :width, :height, :size
      attr_reader :urls

      def initialize(data = {})
        data.each do |k, v|
          send "#{k}=".to_sym, v if respond_to? "#{k}=".to_sym
        end
      end

      def urls=(data)
        @urls = MediaUrl.new URI(data.fetch(:original)), URI(data.fetch(:thumb))
      end
    end

    class Release
      attr_accessor :downloads_count, :file_name, :file_size,
                    :id, :info_json, :sha1, :version
      attr_reader :released_at
      attr_writer :factorio_version, :game_version

      def initialize(data = {})
        data.each do |k, v|
          send "#{k}=".to_sym, v if respond_to? "#{k}=".to_sym
        end
      end

      def factorio_version
        @factorio_version || info_json[:factorio_version]
      end

      def game_version
        @game_version || info_json[:factorio_version]
      end

      def download
        Net::HTTP.get(download_url)
      end

      def download_to(path)
        path = File.join path, file_name if Dir.exist? path

        File.open(path, 'wb') do |file|
          puts "Saving to #{file.path}..."
          store = proc do |resp|
            resp.value
            resp.read_body { |data| file.write(data) }
          end

          Net::HTTP.get_response(download_url) do |resp|
            if resp.is_a? Net::HTTPFound
              Net::HTTP.get_response(URI(resp['location']), &store)
            else
              store.call resp
            end
          end
        end

        dir + path
      end

      def download_url
        @download_url.dup.tap do |url|
          a = FactorioMods::Api::WebAuthentication
          url.query = "username=#{a.username}&token=#{a.token}" if a.token
        end
      end

      def download_url=(url)
        @download_url = URI(FactorioMods::Api::ModPortal::BASE_URL + url)
      end

      def released_at=(time)
        @released_at = Time.parse time
      end
    end

    class Tag
      attr_accessor :id, :name, :title, :description
      attr_reader :type

      def initialize(data = {})
        data.each do |k, v|
          send "#{k}=".to_sym, v if respond_to? "#{k}=".to_sym
        end
      end

      def type=(type)
        @type = type.to_sym
      end
    end

    attr_accessor :current_user_rating, :description, :description_html,
                  :downloads_count, :game_versions, :homepage,
                  :id, :license_name, :license_url, :name, :owner,
                  :ratings_count, :summary, :title, :visits_count
    attr_reader :created_at, :github_path, :license_flags, :license_flags_raw,
                :media_files, :releases, :tags, :updated_at

    def initialize(data = {})
      data.each do |k, v|
        send "#{k}=".to_sym, v if respond_to? "#{k}=".to_sym
      end
    end

    def reload!
      data = FactorioMods::Api::ModPortal.raw_mod(name)
      data.each do |k, v|
        send "#{k}=".to_sym, v if respond_to? "#{k}=".to_sym
      end
      true
    end

    def created_at=(date)
      @created_at = Time.parse date
    end

    def first_media_file
      return media_files.first if media_files
      @first_media_file
    end

    def first_media_file=(file)
      @first_media_file = MediaFile.new file
    end

    def latest_release
      return releases.max { |r| r.released_at.to_i } if releases
      @latest_release
    end

    def latest_release=(release)
      @latest_release = Release.new release
    end

    def github_path=(path)
      @github_path = URI('https://github.com/' + path)
    end

    def license_flags=(flags)
      @license_flags_raw = flags
      @license_flags = begin
        ret = []
        ret << :permit_commercial_use if flags & (1 << 0)
        ret << :permit_modification   if flags & (1 << 1)
        ret << :permit_distribution   if flags & (1 << 2)
        ret << :permit_patent_use     if flags & (1 << 3)
        ret << :permit_private_use    if flags & (1 << 4)

        ret << :must_disclose_source  if flags & (1 << 5)
        ret << :must_license_notice   if flags & (1 << 6)
        ret << :must_same_license     if flags & (1 << 7)
        ret << :must_state_changes    if flags & (1 << 8)

        ret << :cant_hold_liable      if flags & (1 << 9)
        ret << :cant_use_trademark    if flags & (1 << 10)
        ret
      end
    end

    def media_files=(files)
      @media_files = files.map { |file| MediaFile.new file }
    end

    def releases=(releases)
      @releases = releases.map { |release| Release.new release }
    end

    def tags=(tags)
      @tags = tags.map { |tag| Tag.new tag }
    end

    def updated_at=(date)
      @updated_at = Time.parse date
    end
  end
end
