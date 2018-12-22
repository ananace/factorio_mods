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

  desc 'add', 'Adds a mod'
  def add(mod)
    mod = $CLI._mods.get_mod(mod)
    if mod
      puts "#{mod.name} is already installed."
      return
    end
    $CLI._mods.install_mod(mod)
    $CLI._mods.save!
    mod = $CLI._mods.get_mod(mod)
    puts "Installed #{mod.name} (#{mod.info[:version]})"
    invoke :show, []
  end

  desc 'remove', 'Removes a mod'
  def remove(mod)
    mod = $CLI._mods.get_mod(mod)
    $CLI._mods.remove_mod(mod)
    $CLI._mods.save!
    puts "Removed #{mod.name} (#{mod.info[:version]})"
    invoke :show, []
  end

  desc 'enable', 'Enables a mod'
  def enable(mod)
    mod = $CLI._mods.get_mod(mod)
    if mod.enabled
      puts "#{mod.name} is already enabled."
      return
    end
    mod.enabled = true
    $CLI._mods.save!
    puts "Enabled #{mod.name} (#{mod.info[:version]})"
    invoke :show, []
  end

  desc 'disable', 'Disables a mod'
  def disable(mod)
    mod = $CLI._mods.get_mod(mod)
    unless mod.enabled
      puts "#{mod.name} is already disabled."
      return
    end
    mod.enabled = false
    $CLI._mods.save!
    puts "Disabled #{mod.name} (#{mod.info[:version]})"
    invoke :show, []
  end
end

end
end
