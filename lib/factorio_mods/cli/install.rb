class FactorioMods::CLI
  class Install < Thor
    default_command 'list'

    desc 'list', 'List all available installs'
    def list
      puts 'Available installs;'.light_green.bold
      _cli._installs.each.with_index do |f, i|
        default = _cli._install.base_path == f.base_path
        fmt = "#{f.base_path} - #{f.version || '<unknown version>'.light_yellow}"
        fmt += ' [invalid]'.red.bold unless f.valid?
        fmt += ' [headless]'.bold if f.valid? && f.headless?

        puts '  ' + "[#{i + 1}]".bold + "  #{fmt} #{default ? '*'.light_blue : ''}"
      end
    end

    desc 'show', 'Shows information about the install'
    def show
      return unless Install.ensure_valid
      puts format(
        '%sFactorio v%s installed at %s',
        _cli._install.headless? ? 'Headless ' : '',
        (_cli._install.version || '<unknown>').bold,
        _cli._install.base_path
      )

      puts
      puts format(
        '%s mod(s), %s enabled, %s disabled.',
        _cli._mods.mods.count.to_s.bold,
        _cli._mods.enabled_mods.count.to_s.light_green,
        _cli._mods.disabled_mods.count.to_s.light_red
      )
    end

    desc 'config', 'Shows configuration set on an install'
    def config
      return unless Install.ensure_valid

      invoke :show, []

      puts
      cfg = _cli._install.config.to_h
      cfg.each do |section, settings|
        settings.each do |key, value|
          puts format(
            '  %s.%s => %s',
            section,
            key,
            value.inspect
          )
        end
      end
    end

    desc 'launch [NAME]', 'Launches the active (or named) install'
    def launch(install = nil)
      raise NotImplementedError, 'Not implemented'
    end

    desc 'add PATH', 'Adds a manual install'
    def add(path)
      install = FactorioMods::Install.new path
      (_cli._cache[:installs] ||= []) << install.base_path
    end

    desc 'remove PATH/NUM', 'Removes a manual install'
    def remove(install)
      return if _cli._cache.additional_installs.empty?

      if install =~ /^\d+$/
        num = install.to_i
        if num < 1 || num > _cli._installs.count
          puts 'Invalid install number'
          return
        end
        install = _cli._installs[num - 1].base_path
      end

      _cli._cache[:installs].delete_if { |f| f == install }
    end

    desc 'set NUM', 'Sets the default install'
    def set(num)
      num = num.to_i
      if num < 1 || num > _cli._installs.count
        puts 'Invalid install number'
        return
      end

      install = _cli._installs[num - 1]
      return unless install.valid?

      _cli._cache[:default_install] = install.base_path
      _cli.instance_variable_set :@install, nil
      puts format(
        '%sFactorio install %s at %s set to default.',
        install.headless? ? 'Headless ' : '',
        (install.version || '<unknown>').bold,
        install.base_path
      )
    end

    def self.ensure_valid
      return true if FactorioMods::CLI.singleton._install.valid?

      if options[:install]
        puts 'Error: Given install is invalid.'
      else
        puts 'Error: Current install is invalid.'
      end
      false
    end

    no_commands do
      def _cli
        FactorioMods::CLI.singleton
      end
    end
  end
end
