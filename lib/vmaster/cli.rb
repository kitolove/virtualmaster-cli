require 'yaml'
require 'deltacloud_vm/client'

module VirtualMaster
  class CLI
    @@config_file = nil
    @@api = nil
    @@config = nil
    @@callbacks = []

    def self.run
      @@config_file = File.join(ENV["HOME"], ".virtualmaster")

      yield
    end

    def self.config_file(config)
      @@config_file = config
    end

    def self.api
      self.config unless @@config

      abort "No configuration available! Please run 'virtualmaster config' first!" unless @@api
      @@api
    end

    def self.config
      unless @@config
        if File.exists? @@config_file
          config = YAML::load(File.open(@@config_file))

          @@config = config.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

          unless @@config[:profiles]
            puts "WARNING: Please, reconfigure virtualmaster-cli (delete your '~/.virtualmaster' and run `virtualmaster config` again). This way you can use custom instance profiles correctly (new in version 0.0.5)"
            puts
          end

          begin
            @@api = DeltacloudVM::Client(VirtualMaster::DEFAULT_URL, @@config[:username], @@config[:password])
          rescue DeltacloudVM::Client::BackendError => e
            abort "Invalid API response: #{e.message}"
          rescue Exception => e
            abort "Unable to connect to Virtualmaster's DeltaCloud API: #{e.message}" 
          end
        else 
          abort "Specified configuration file (#{config_file}) does not exist!"
        end
      end

      @@config
    end

    def self.callbacks
      @@callbacks
    end
  end
end

