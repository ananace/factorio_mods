require 'inifile'

module FactorioMods
  class Install
    attr_reader :base_path, :architecture

    def self.discover
      to_scan = if FactorioMods::OS.windows?
                  [
                    'C:\Program Files (x86)\Steam\steamapps\common\Factorio',
                    'C:\Program Files\Factorio'
                  ]
                elsif FactorioMods::OS.mac?
                  [
                    '~/Library/Application Support/Steam/steamapps/common/Factorio/factorio.app/Contents',
                    '/Applications/factorio.app/Contents'
                  ]
                elsif FactorioMods::OS.linux?
                  [
                    '~/.steam/steam/steamapps/common/Factorio',
                    '~/.var/app/com.valvesoftware.Steam/.steam/steam/steamapps/common/Factorio',
                    '~/.factorio',
                    '~/.var/app/com.valvesoftware.Steam/.factorio'
                  ]
                end

      to_scan.map { |path| Install.new path }.select(&:valid?)
    end

    def initialize(path)
      @base_path = File.expand_path path
      return unless valid?

      @architecture = Dir.entries(File.join(base_path, 'bin'))
                         .reject { |e| e.start_with? '.' }
                         .first
    end

    def mod_manager
      @mod_manager ||= ModManager.new self
    end

    def config
      @config ||= IniFile.load(File.join(system_path, 'config', 'config.ini'))
    end

    def binary
      if OS.windows?
        File.join bin_path, 'factorio.exe'
      else
        File.join bin_path, 'factorio'
      end
    end

    def read_path
      @read_path ||= begin
        if uses_system_paths
          config['path']['read-data']
            .gsub('__PATH__system-read-data__', system_path)
            .gsub('__PATH__system-write-data__', system_path)
            .gsub('__PATH__executable__', base_path)
        else
          base_path
        end
      end
    end

    def write_path
      @write_path ||= begin
        if uses_system_paths
          config['path']['write-data']
            .gsub('__PATH__system-read-data__', system_path)
            .gsub('__PATH__system-write-data__', system_path)
            .gsub('__PATH__executable__', base_path)
        else
          base_path
        end
      end
    end

    def bin_path
      File.join base_path, 'bin', architecture
    end

    def data_path
      File.join base_path, 'data'
    end

    def modlist_path
      File.join mods_path, 'mod-list.json'
    end

    def mods_path
      File.join write_path, 'mods'
    end

    def saves_path
      File.join write_path, 'saves'
    end

    def mod_path(mod)
      if %w[base core].include? mod.to_s
        File.join data_path, mod
      else
        matching = Dir.entries(mods_path).select { |entry| entry.start_with?(mod) }
        return nil unless matching.any?
        raise 'More than one mod matches' if matching.count > 1

        File.join(mods_path, matching.first)
      end
    end

    def valid?
      Dir.exist?(base_path) &&
        File.exist?(File.join(mod_path('base'), 'info.json'))
    end

    def headless?
      binary_info.include? 'headless'
    end

    def steam?
      !(base_path.tr('\\', '/').downcase =~ %r{/steamapps/common/}i).nil?
    end

    def version
      return nil unless @architecture && Dir.exist?(bin_path) && File.exist?(File.join(bin_path, 'factorio'))
      binary_info.match(/Version: (\S+)/)[1]
    end

    protected

    def system_path
      File.expand_path(if FactorioMods::OS.windows?
                         File.join '%appdata%', 'Factorio'
                       elsif FactorioMods::OS.mac?
                         File.join '~', 'Library', 'Application Support', 'factorio'
                       elsif FactorioMods::OS.linux?
                         File.join '~', '.factorio'
                       end)
    end

    def uses_system_paths
      @uses_system_paths ||= begin
        config = IniFile.load File.join(base_path, 'config-path.cfg')
        config['global']['use-system-read-write-data-directories']
      end
    end

    private

    def binary_info
      @binary_info ||= `#{File.join bin_path, 'factorio'} --version`
    end
  end
end
