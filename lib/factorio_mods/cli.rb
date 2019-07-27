require 'colorize'
require 'factorio_mods'
require 'logging'
require 'thor'

class FactorioMods::CLI < Thor
  autoload :Cache, 'factorio_mods/cli/cache'
  autoload :Install, 'factorio_mods/cli/install'
  autoload :Mod, 'factorio_mods/cli/mod'
  autoload :Pack, 'factorio_mods/cli/pack'

  option :install, type: :string
  # option :verbose { Logging::Logger[FactorioMods].level = :debug }

  def self.exit_on_failure?
    true
  end

  def initialize(*args)
    super

    self.class.send :singleton=, self

    return unless _cache.authed?

    FactorioMods::Api::WebAuthentication.username = _cache.username
    FactorioMods::Api::WebAuthentication.token = _cache.token
  end

  desc 'login', 'Log in to the Factorio web API'
  def login(user, pass)
    FactorioMods::Api::WebAuthentication.login(user, pass)

    _cache[:username] = FactorioMods::Api::WebAuthentication.username
    _cache[:token] = FactorioMods::Api::WebAuthentication.token
  end

  desc 'install', '', hide: true
  subcommand 'install', Install
  desc 'installs', '', hide: true
  subcommand 'installs', Install

  desc 'mod', '', hide: true
  subcommand 'mod', Mod
  desc 'mods', '', hide: true
  subcommand 'mods', Mod

  desc 'pack', '', hide: true
  subcommand 'pack', Pack
  desc 'packs', '', hide: true
  subcommand 'packs', Pack

  # Need to do all non-command code in the block
  #
  # rubocop:disable Metrics/BlockLength
  no_commands do
    def _cache_path
      File.expand_path('~/.cache/factorio-manager.json')
    end

    def _cache
      @_cache ||= Cache.new(JSON.parse(File.read(_cache_path), symbolize_names: true)) if File.exist? _cache_path
      @_cache ||= Cache.new
    end

    def _save_cache
      File.write(_cache_path, JSON.generate(_cache))
    end

    def _installs
      (@installs ||= FactorioMods::Install.discover) + _cache.additional_installs
    end

    def _install
      if options[:install]
        install = _installs.find { |f| f.base_path == options[:install] }
        return install if install
        return FactorioMods::Install.new options[:install]
      end

      return @install if @install

      if _cache.key? :default_install
        default = _cache.default_install

        @install = default if default.is_a? FactorioMods::Install
        @install ||= _installs[default] if default.is_a? Numeric
        @install ||= _installs.find { |f| f.base_path == default } if default.is_a? String
      else
        @install = _installs.first
      end
      @install
    end

    def _mods
      @mods ||= _install.mod_manager
    end
  end

  class << self
    def singleton
      @cli
    end

    private

    def singleton=(obj)
      raise 'Already set' unless @cli.nil?

      @cli = obj
    end
  end
end
