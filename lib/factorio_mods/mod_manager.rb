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
      @mod_list = JSON.parse(File.read(install.modlist_path), symbolize_names: true)[:mods].map do |mod|
        InstalledMod.new(self, mod[:name], mod[:enabled])
      end
    end

    def save!
      data = {
        mods: @mod_list.map do |mod|
          {
            name: mod.name,
            enabled: mod.enabled
          }
        end
      }
      File.write(install.modlist_path, JSON.generate(data, indent: '  ', space: ' ', array_nl: "\n", object_nl: "\n"))
    end

    def install_mod(mod, options = {})
      mod = FactorioMods::Api::ModPortal.mod mod.to_s unless mod.is_a? FactorioMods::Mod
      mod.reload! unless mod.releases

      release = mod.releases
                   .select { |r| install.version.start_with? r.factorio_version }

      release = if options[:version]
                  release.find do |r|
                    # Use rubygems version matching, to support things like '~> 1.0'
                    Gem::Dependency('', options[:version]).match?('', r.version)
                  end
                else
                  release.max { |r| r.released_at.to_i }
                end

      release.download_to(install.mods_path)

      @mod_list << InstalledMod.new(self, mod.name, true)
      @mod_list.sort! do |a, b|
        return -1 if CORE_MODS.include? a.name
        return 1  if CORE_MODS.include? b.name

        a.name <=> b.name
      end
    end

    def remove_mod(mod)
      file = install.mod_path(mod)

      if file
        Dir.delete file if File.directory? file
        File.delete file if File.file? file
      end

      @mod_list.delete_if { |m| m.name == mod }
    end

    def enable_mod(mod)
      entry = @mod_list.find { |m| m.name == mod }
      entry.enabled = true if entry
    end

    def disable_mod(mod)
      entry = @mod_list.find { |m| m.name == mod }
      entry.enabled = false if entry
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
