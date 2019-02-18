module FactorioMods
class CLI

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
  end

  desc 'delete PACK', 'Deletes a new modpack'
  def delete(pack)
  end

  desc 'use PACK', 'Switches to a specific modpack'
  def use(pack)
  end

end

end
end
