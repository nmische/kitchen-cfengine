require "kitchen"
require "kitchen/util"
require "kitchen/provisioner/base"
require "kitchen/provisioner/cfengine_version"

module Kitchen
  module Provisioner

    class Cfengine < Base

      default_config :cfenging_type, "community"
      default_config :cfengine_community_quick_install_url, "http://s3.amazonaws.com/cfengine.packages/quick-install-cfengine-community.sh"
      default_config :cfengine_enterprise_quick_install_url, "http://s3.amazonaws.com/cfengine.packages/quick-install-cfengine-enterprise.sh"
      default_config :chef_omnibus_url, "https://www.getchef.com/chef/install.sh"
      default_config :cfengine_policy_server_address, ""
      default_config :cf_agent_args, "-KI"
      default_config :run_list, []
      default_config :cfengine_files do |provisioner|
        provisioner.calculate_path("test/cfengine_files")
      end
      expand_path_for :cfengine_files


      def create_sandbox
        super
        prepare_files
      end

      def install_command
        lines = [Kitchen::Util.shell_helpers, install_cfengine, install_busser]
        lines.join("\n")
      end

      def init_command
        if config[:cfengine_policy_server_address] == ""
          <<-INIT
            if [ ! -e "/var/cfengine/policy_server.dat" ]
              then
              LANG=en /sbin/ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1 }' | head -n 1 | xargs #{sudo('/var/cfengine/bin/cf-agent')} --bootstrap
            fi
          INIT
        else
          <<-INIT
            if [ ! -e "/var/cfengine/policy_server.dat" ]
              then
              #{sudo('/var/cfengine/bin/cf-agent')} --bootstrap #{config[:cfengine_policy_server_address]}
            fi
          INIT
        end
      end

      def prepare_command
        <<-PREP
          #{sudo('cp')} -rf #{config[:root_path]}/* /var/cfengine
          #{sudo('/var/cfengine/bin/cf-agent')} -KI -f failsafe.cf
        PREP
      end

      def run_command
        cmd = [sudo("/var/cfengine/bin/cf-agent"), config[:cf_agent_args]]
        cmd << "-f" << config[:run_list] if config[:run_list].length > 0
        cmd.join(" ").strip
      end



      def prepare_files
        return unless config[:cfengine_files]

        info("Preparing cfengine files")
        debug("Using cfengine files from #{config[:cfengine_files]}")

        tmpdata_dir = File.join(sandbox_path, "cfengine_files")
        FileUtils.mkdir_p(tmpdata_dir)
        FileUtils.cp_r(Dir.glob("#{config[:cfengine_files]}/*"), tmpdata_dir)
      end

      def install_cfengine
        <<-INSTALL
        if [ ! -d "/var/cfengine" ]
          then
          echo "-----> Installing cfengine (#{config[:cfenging_type]})"
          do_download #{cfengine_quick_install_url} /tmp/install.sh
          #{sudo('sh')} /tmp/install.sh
        fi
        INSTALL
      end

      def install_busser
        <<-INSTALL
        # install chef omnibus so that busser works as this is needed to run tests :(
        # TODO: work out how to install enough ruby and set
        # busser: { :ruby_bindir => '/usr/bin/ruby' } so that we dont need the
        # whole chef client
        if [ ! -d "/opt/chef" ]
          then
          echo "-----> Installing Chef Omnibus to install busser to run tests"
          do_download #{config[:chef_omnibus_url]} /tmp/install.sh
          #{sudo('sh')} /tmp/install.sh
        fi
        INSTALL
      end

      def cfengine_quick_install_url
        if config[:cfenging_type] == "community"
          config[:cfengine_community_quick_install_url]
        else
          config[:cfengine_enterprise_quick_install_url]
        end
      end

    end

  end
end
