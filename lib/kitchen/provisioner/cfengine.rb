require "kitchen"
require "kitchen/util"
require "kitchen/provisioner/base"
require "kitchen/provisioner/cfengine_version"

module Kitchen
  module Provisioner

    class Cfengine < Base

      default_config :require_cfengine_quick_install, true
      default_config :cfenging_type, "community"
      default_config :cfengine_community_quick_install_url, "http://s3.amazonaws.com/cfengine.packages/quick-install-cfengine-community.sh"
      default_config :cfengine_enterprise_quick_install_url, "http://s3.amazonaws.com/cfengine.packages/quick-install-cfengine-enterprise.sh"
      default_config :chef_omnibus_url, "https://www.getchef.com/chef/install.sh"
      default_config :cfengine_policy_server_address, "127.0.0.1"
      default_config :cf_agent_args, ""

      def install_command
        return unless config[:require_cfengine_quick_install]
        lines = [Kitchen::Util.shell_helpers, install_cfengine, install_busser]
        lines.join("\n")
      end

      def init_command
        cmd = [sudo("/var/cfengine/bin/cf-agent"), "--bootstrap #{config[:cfengine_policy_server_address]}"]
        cmd.join(" ").strip
      end

      # (see Base#run_command)
      def run_command
        cmd = [sudo("/var/cfengine/bin/cf-agent"), config[:cf_agent_args]]
        cmd.join(" ").strip
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
