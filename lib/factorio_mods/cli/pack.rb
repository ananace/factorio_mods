class FactorioMods::CLI
  class Pack < Thor
    default_command :show

    map 'list' => :show
    map 'create' => :new
    map 'del' => :delete
    map 'remove' => :delete
    map 'rm' => :delete

    desc 'show', 'Lists all modpacks'
    def show
      puts '* vanilla'
    end

    desc 'new PACK', 'Creates a new modpack'
    def new(pack)
      mods = $CLI._mods.enabled_mods
      pack = Object.new

      # Store pack

      true
    end

    desc 'delete PACK', 'Deletes a new modpack'
    def delete(pack)
      true
    end

    desc 'use PACK', 'Switches to a specific modpack'
    def use(pack)
      true
    end
  end
end
