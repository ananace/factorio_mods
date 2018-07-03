require 'gem/dependency'

module FactorioMods
  class ModManager
    attr_reader :install

    def initialize(install)
      @install = install
      return unless install.valid?

      @mod_list = JSON.parse(File.read(install.modlist_path), symbolize_names: true)
    end

    def reload!
      @mod_list = JSON.parse(File.read(install.modlist_path), symbolize_names: true)
    end

    def save!
      File.write(install.modlist_path, JSON.generate(mod_list, indent: '  '))
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
      enable_mod mod
    end

    def remove_mod(mod)
      mod = FactorioMods::Api::ModPortal.mod mod.to_s unless mod.is_a? FactorioMods::Mod

      file = install.mod_path(mod.name)
      Dir.delete file if Dir.exist? file
      File.delete file if File.exist? file
      @mod_list[:mods].delete_if { |m| m[:name] == mod.name }
    end

    def enable_mod(mod)
      mod = FactorioMods::Api::ModPortal.mod mod.to_s unless mod.is_a? FactorioMods::Mod

      entry = @mod_list[:mods].find { |m| m[:name] == mod.name }
      entry ||= begin
        e = @mod_list[:mods] << { mod: mod.name, enabled: true }
        @mod_list[:mods].sort! { |a, b| a[:name] <=> b[:name] }
        e
      end

      entry[:enabled] = true
    end

    def disable_mod(mod)
      mod = FactorioMods::Api::ModPortal.mod mod.to_s unless mod.is_a? FactorioMods::Mod

      entry = @mod_list[:mods].find { |m| m[:name] == mod.name }
      entry[:enabled] = false if entry
    end

    def mods
      @mod_list[:mods].map { |m| m[:name] }
    end

    def disabled_mods
      @mod_list[:mods].reject { |m| m[:enabled] }.map { |m| m[:name] }
    end

    def enabled_mods
      @mod_list[:mods].select { |m| m[:enabled] }.map { |m| m[:name] }
    end
  end
end
