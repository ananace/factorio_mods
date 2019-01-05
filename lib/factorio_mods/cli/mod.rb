module FactorioMods
class CLI

class Mod < Thor
  default_command :show

  map 'list' => :show

  desc 'show', 'Lists all mods'
  def show
    puts "Using Factorio #{$CLI._install.version.bold} @ #{$CLI._install.mods_path}\n\n"
    puts 'Installed mods;'.light_green.bold
    $CLI._mods.mods.each do |mod|
      puts "#{mod.enabled ? '+'.light_green.bold : '-'.light_yellow.bold} #{mod.name} (#{mod.info[:version]})"
    end
  end

  desc 'sort', 'Resort mods'
  def sort
    $CLI._mods.mods.sort_mods!
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'search STRING', 'Searches the online repository'
  def search(string)

  end

  desc 'add MOD', 'Adds a mod'
  def add(mod)
    $CLI._mods.install_mod(mod)
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'update MOD', 'Updates a mod'
  def update(mod)
    # TODO: Improve
    $CLI._mods.remove_mod(mod)
    $CLI._mods.install_mod(mod)
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'remove MOD', 'Removes a mod'
  def remove(mod)
    $CLI._mods.remove_mod(mod)
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'enable MOD', 'Enables a mod'
  def enable(mod)
    $CLI._mods.enable_mod mod
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'disable MOD', 'Disables a mod'
  def disable(mod)
    $CLI._mods.disable_mod mod
    $CLI._mods.save!
    invoke :show, []
  end
end

end
end
