# Factorio management gem

The main focus for this gem is for modding and management of mods, but it contains APIs for more uses than that.

## Installation

Install it with gem

    $ gem install factorio_mods

## Usage

TODO: Implement thor-based CLI

```ruby
# Acquire a token
FactorioMods::Api::WebAuthentication.login 'username', 'password'
# or
FactorioMods::Api::WebAuthentication.tap do |auth|
  auth.username = 'username'
  auth.token    = 'token'
end

install = FactorioMods::Install.new '~/.factorio'
# or
install = FactorioMods::Install.discover.first

install.mod_manager.install_mod('angelssmelting')
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ananace/factorio_mods

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
