module FactorioMods
class CLI

class Mod < Thor
  default_command 'show'

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
    $CLI._mods.install_mod(mod)
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'remove', 'Removes a mod'
  def remove(mod)
    $CLI._mods.remove_mod(mod)
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'enable', 'Enables a mod'
  def enable(mod)
    $CLI._mods.enable_mod mod
    $CLI._mods.save!
    invoke :show, []
  end

  desc 'disable', 'Disables a mod'
  def disable(mod)
    $CLI._mods.disable_mod mod
    $CLI._mods.save!
    invoke :show, []
  end
end

end
end
