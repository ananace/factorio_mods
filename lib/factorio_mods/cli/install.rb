class FactorioMods::CLI
  class Install < Thor
    default_command 'list'

    desc 'list', 'List all available installs'
    def list
      puts 'Available installs;'.light_green.bold
      $CLI._installs.each.with_index do |f, i|
        default = $CLI._install.base_path == f.base_path
        fmt = "#{f.base_path} - #{f.version || '<unknown version>'.light_yellow}"
        fmt += ' [invalid]'.red.bold unless f.valid?
        fmt += ' [headless]'.bold if f.valid? && f.headless?

        puts '  ' + "[#{i + 1}]".bold + "  #{fmt} #{default ? '*'.light_blue : ''}"
      end
    end

    desc 'show', 'Shows information about the install'
    def show
      return unless Install.ensure_valid
      puts "#{$CLI._install.headless? ? 'Headless ' : ''}Factorio v#{($CLI._install.version || '<unknown>').bold} installed at #{$CLI._install.base_path}"
      puts
      puts "#{$CLI._mods.mods.count.to_s.bold} mod(s), #{$CLI._mods.enabled_mods.count.to_s.light_green} enabled, #{$CLI._mods.disabled_mods.count.to_s.light_red} disabled."
    end

    desc 'add PATH', 'Adds a manual install'
    def add(path)
      install = FactorioMods::Install.new path
      ($CLI._cache[:installs] ||= []) << install.base_path
    end

    desc 'remove PATH/NUM', 'Removes a manual install'
    def remove(install)
      return if $CLI._cache.additional_installs.empty?

      if install =~ /^\d+$/
        num = install.to_i
        if num < 1 || num > $CLI._installs.count
          puts 'Invalid install number'
          return
        end
        install = $CLI._installs[num - 1].base_path
      end

      $CLI._cache[:installs].delete_if { |f| f == install }
    end

    desc 'set NUM', 'Sets the default install'
    def set(num)
      num = num.to_i
      if num < 1 || num > $CLI._installs.count
        puts 'Invalid install number'
        return
      end

      install = $CLI._installs[num - 1]
      return unless install.valid?

      $CLI._cache[:default_install] = install.base_path
      $CLI.instance_variable_set :@install, nil
      puts "#{install.headless? ? 'Headless ' : ''}Factorio install #{(install.version || '<unknown>').bold} at #{install.base_path} set to default."
    end

    def self.ensure_valid
      return true if $CLI._install.valid?

      if options[:install]
        puts 'Error: Given install is invalid.'
      else
        puts 'Error: Current install is invalid.'
      end
      false
    end
  end
end
