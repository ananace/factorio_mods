module FactorioMods
class CLI

class Mod < Thor
  default_command :show

  map 'list' => :show
  map 'install' => :add
  map 'rm' => :remove
  map 'uninstall' => :remove

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
    $CLI._mods.sort_mods!
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'search STRING', 'Searches the online repository'
  def search(string)

  end

  desc 'add MOD...', 'Adds a mod'
  def add(*mods)
    mods.each do |mod|
      $CLI._mods.install_mod(mod)
      mod = $CLI._mods.get_mod(mod)
      puts "Installed mod #{mod.name} (#{mod.info[:version]})"
    end
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'update MOD...', 'Updates a mod'
  def update(*mods)
    # TODO: Improve
    mods.each do |mod|
      mod = $CLI._mods.get_mod(mod)
      next unless mod
      $CLI._mods.remove_mod(mod)
      $CLI._mods.install_mod(mod)
      after = $CLI._mods.get_mod(mod)
      puts "Updated mod #{mod.name} #{mod.info[:version]} => #{after.info[:version]}"
    end
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'remove MOD...', 'Removes a mod'
  def remove(*mods)
    mods.each do |mod|
      mod = $CLI._mods.get_mod(mod)
      next unless mod
      $CLI._mods.remove_mod(mod)
      puts "Removed mod #{mod.name}"
    end
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'enable MOD...', 'Enables a mod'
  def enable(*mods)
    mods.each do |mod|
      mod = $CLI._mods.get_mod(mod)
      next unless mod
      next if mod.enabled
      $CLI._mods.enable_mod mod
      puts "Enabled mod #{mod.name}"
    end
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'disable MOD...', 'Disables a mod'
  def disable(*mods)
    mods.each do |mod|
      mod = $CLI._mods.get_mod(mod)
      next unless mod
      next unless mod.enabled
      $CLI._mods.disable_mod mod
      puts "Disabled mod #{mod.name}"
    end
    $CLI._mods.save!
    invoke :show, []
  end
end

end
end
