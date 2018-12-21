module FactorioMods
class CLI

class Install < Thor
  default_command 'list'

  desc 'list', 'List all available installs'
  def list
    puts 'Available installs;'.light_green.bold
    $CLI._installs.each.with_index do |f, i|
      default = $CLI._install.base_path == f.base_path
      puts '  ' + "[#{i + 1}]".bold + "  #{f.base_path} - #{f.version} #{default ? '*'.light_blue : ''}"
    end
  end

  desc 'show', 'Shows information about the install'
  def show
    puts "Factorio version #{$CLI._install.version.bold} installed at #{$CLI._install.base_path}"
    puts
    puts "#{$CLI._mods.mods.count.to_s.bold} mod(s), #{$CLI._mods.enabled_mods.count.to_s.light_green} enabled, #{$CLI._mods.disabled_mods.count.to_s.light_red} disabled."
  end

  desc 'add PATH', 'Adds a manual install'
  def add(path)
    
  end

  desc 'set NUM', 'Sets the default install'
  def set(num)
    num = num.to_i
    if num < 1 || num > $CLI._installs.count
      puts 'Invalid install number'
      return
    end

    $CLI._cache[:default_install] = $CLI._installs[num - 1].base_path
    $CLI.instance_variable_set :@install, nil
    puts "Factorio install #{$CLI._install.version.bold} at #{$CLI._install.base_path} set to default."
  end

end

end
end
