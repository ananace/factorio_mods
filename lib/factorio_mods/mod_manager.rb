begin
  require 'rubygems/dependency'
rescue LoadError
  require 'gem/dependency'
end
require 'zip'

module FactorioMods
  InstalledMod = Struct.new(:manager, :name, :enabled) do
    def info
      @info ||= begin
        mod = manager.install.mod_path(name)
        if File.file? mod
          Zip::File.open(mod) do |zip|
            file = zip.glob('**/info.json').first
            JSON.parse(zip.read(file), symbolize_names: true)
          end
        else
          JSON.parse(File.read(File.join(mod, 'info.json')), symbolize_names: true)
        end
      rescue StandardError => ex
        { error: ex }
      end
    end

    def to_s
      name
    end
  end

  class ModManager
    CORE_MODS = %w[base core].freeze

    attr_reader :install

    def initialize(install)
      @install = install
      return unless install.valid?

      reload!
    end

    def reload!
      @mod_list = if File.exist? install.modlist_path
                    JSON.parse(File.read(install.modlist_path), symbolize_names: true)[:mods].map do |mod|
                      InstalledMod.new(self, mod[:name], mod[:enabled])
                    end
                  else
                    [InstalledMod.new(self, 'base', true)]
                  end
    end

    def save!
      ensure_moddir!
      data = {
        mods: mods.map do |mod|
          {
            name: mod.name,
            enabled: mod.enabled
          }
        end
      }
      File.write(install.modlist_path, JSON.generate(data, indent: '  ', space: ' ', array_nl: "\n", object_nl: "\n"))
    end

    def ensure_moddir!
      Dir.mkdir install.mods_path unless Dir.exist? install.mods_path
    end

    def install_mod(mod, options = {})
      ensure_moddir!
      mod = FactorioMods::Api::ModPortal.mod mod.to_s unless mod.is_a? FactorioMods::Mod
      raise 'Failed to look up mod' unless mod

      mod.reload! unless mod.releases

      release = mod.releases
                   .select { |r| install.version.start_with? r.factorio_version }

      raise "No releases for Factorio version #{install.version}" if release.empty?

      release = if options[:version]
                  release.find do |r|
                    # Use rubygems version matching, to support things like '~> 1.0'
                    Gem::Dependency('', options[:version]).match?('', r.version)
                  end
                else
                  release.max { |r| r.released_at.to_i }
                end

      raise "Unable to find a release matching #{options[:version]}" if options[:version] && release.nil?

      release.download_to(install.mods_path)

      @mod_list << InstalledMod.new(self, mod.name, true)
      sort_mods!
    end

    def remove_mod(mod)
      mod = mod.to_s unless mod.is_a? String
      file = install.mod_path(mod)

      if file
        Dir.delete file if File.directory? file
        File.delete file if File.file? file
      end

      mods.delete_if { |m| m.name == mod }
    end

    def update_mod(mod)
      local_mod = get_mod(mod)
      raise 'Not installed' unless local_mod

      mod = FactorioMods::Api::ModPortal.mod mod.to_s unless mod.is_a? FactorioMods::Mod
      raise 'Unable to find mod' unless mod

      mod.reload! unless mod.releases

      release = mod.releases
                   .select { |r| install.version.start_with? r.factorio_version }
                   .max { |r| r.released_at.to_i }

      cur_release = local_mod.info[:version]

      return false if release.version == cur_release

      cur_file = install.mod_path(local_mod.name)
      if cur_file
        Dir.delete cur_file if File.directory? cur_file
        File.delete cur_file if File.file? cur_file
      end

      local_mod.instance_variable_set :@info, nil
      release.download_to(install.mods_path)
      true
    end

    def enable_mod(mod)
      entry = get_mod(mod)
      entry.enabled = true if entry
    end

    def disable_mod(mod)
      return if mod == 'base'

      entry = get_mod(mod)
      entry.enabled = false if entry
    end

    def get_mod(mod)
      mod = mod.to_s unless mod.is_a? String
      mods.find { |m| m.name == mod }
    end

    def sort_mods!
      @mod_list = mods.uniq(&:name).sort do |a, b|
        if CORE_MODS.include? a.name
          -1
        elsif CORE_MODS.include? b.name
          1
        else
          a.name.downcase <=> b.name.downcase
        end
      end
    end

    def mods
      @mod_list
    end

    def disabled_mods
      @mod_list.reject(&:enabled)
    end

    def enabled_mods
      @mod_list.select(&:enabled)
    end
  end
end
