class FactorioMods::CLI
  class Mod < Thor
    default_command :show

    map 'list' => :show
    map 'install' => :add
    map 'rm' => :remove
    map 'uninstall' => :remove

    desc 'show', 'Lists all mods'
    def show
      puts "Using Factorio #{_cli._install.version.bold} @ #{_cli._install.mods_path}\n\n"
      puts 'Installed mods;'.light_green.bold
      _cli._mods.mods.each do |mod|
        puts "#{mod.enabled ? '+'.light_green.bold : '-'.light_yellow.bold} #{mod.name} (#{mod.info[:version]})"
      end
    end

    desc 'sort', 'Resort mods'
    def sort
      _cli._mods.sort_mods!
      _cli._mods.save!
      invoke :show, []
    end

    desc 'search STRING', 'Searches the online repository'
    def search(_string)
      raise NotImplementedError, 'Mod search is not implemented yet'
    end

    desc 'add MOD...', 'Adds a mod'
    def add(*mods)
      mods.each do |mod|
        _cli._mods.install_mod(mod)
        mod = _cli._mods.get_mod(mod)
        puts "Installed mod #{mod.name} (#{mod.info[:version]})"
      end
      _cli._mods.save!
      invoke :show, []
    end

    desc 'update MOD...|all', 'Updates a mod'
    def update(*mods)
      if mods.size == 1 && mods.first == 'all'
        mods = _cli._mods.mods.map(&:name)
        mods.delete 'base'
        mods.delete 'core'
      end

      mods.each do |mod|
        mod = _cli._mods.get_mod(mod)
        next unless mod
        updated = _cli._mods.update_mod(mod)
        after = _cli._mods.get_mod(mod)
        puts "Updated mod #{mod.name} from #{mod.info[:version]} => #{after.info[:version]}" if updated
      end
      _cli._mods.save!
      invoke :show, []
    end

    desc 'remove MOD...', 'Removes a mod'
    def remove(*mods)
      mods.each do |mod|
        mod = _cli._mods.get_mod(mod)
        next unless mod
        _cli._mods.remove_mod(mod)
        puts "Removed mod #{mod.name}"
      end
      _cli._mods.save!
      invoke :show, []
    end

    desc 'enable MOD...', 'Enables a mod'
    def enable(*mods)
      mods.each do |mod|
        mod = _cli._mods.get_mod(mod)
        next unless mod
        next if mod.enabled
        _cli._mods.enable_mod mod
        puts "Enabled mod #{mod.name}"
      end
      _cli._mods.save!
      invoke :show, []
    end

    desc 'disable MOD...', 'Disables a mod'
    def disable(*mods)
      mods.each do |mod|
        mod = _cli._mods.get_mod(mod)
        next unless mod
        next unless mod.enabled
        _cli._mods.disable_mod mod
        puts "Disabled mod #{mod.name}"
      end
      _cli._mods.save!
      invoke :show, []
    end

    no_commands do
      def _cli
        FactorioMods::CLI.singleton
      end
    end
  end
end
