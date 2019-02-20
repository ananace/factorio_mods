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
      raise NotImplementedError
    end

    desc 'new PACK', 'Creates a new modpack'
    def new(_pack)
      raise NotImplementedError
      # mods = _cli._mods.enabled_mods
      # pack = Object.new

      # Store pack
    end

    desc 'delete PACK', 'Deletes a new modpack'
    def delete(_pack)
      raise NotImplementedError
    end

    desc 'use PACK', 'Switches to a specific modpack'
    def use(_pack)
      raise NotImplementedError
    end

    no_commands do
      def _cli
        FactorioMods::CLI.singleton
      end
    end
  end
end
