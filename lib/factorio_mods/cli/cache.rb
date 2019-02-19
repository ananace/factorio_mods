class FactorioMods::CLI
  module Cache
    def self.new(data = {})
      data.extend(Extensions)
      data
    end

    module Extensions
      def authed?
        key?(:username) && key?(:token)
      end

      def additional_installs
        return [] unless key? :installs
        installs.map { |path| FactorioMods::Install.new path }
      end

      def respond_to_missing?(name, *_args)
        key? name
      end

      def method_missing(name, *args)
        return fetch(name) if key?(name) && args.empty?
        super
      end
    end
  end
end
