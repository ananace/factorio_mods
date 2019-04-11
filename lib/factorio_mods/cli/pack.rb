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
      puts "Available mod packs:"
      (_cli._cache[:packs] ||= {}).each do |k,_v|
        puts "- #{k}"
      end
    end

    desc 'new PACK', 'Creates a new modpack'
    def new(pack)
      mods = _cli._mods.enabled_mods
      mods = mods.map(&:name)

      (_cli._cache[:packs] ||= {})[pack.to_s.to_sym] = mods

      puts "Created #{pack}"
    end

    desc 'delete PACK', 'Deletes a new modpack'
    def delete(pack)
      (_cli._cache[:packs] ||= {}).delete pack.to_s.to_sym

      puts "Removed #{pack}"
    end

    desc 'use PACK', 'Switches to a specific modpack'
    def use(name)
      pack = (_cli._cache[:packs] ||= {})[name.to_s.to_sym]

      if pack.nil?
        puts "Unable to find pack #{name}"
        return
      end

      puts "Enabling pack #{name}..."

      _cli._mods.mods.each { |m| m.enabled = false }
      pack.each do |m|
        _cli._mods.enable_mod(m)
      end
      _cli._mods.save!
    end

    no_commands do
      def _cli
        FactorioMods::CLI.singleton
      end
    end
  end
end
