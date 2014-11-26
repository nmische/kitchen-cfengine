# Kitchen::Provisioner::Cfengine

A CFEngine Provisioner for Test Kitchen.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kitchen-cfengine'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kitchen-cfengine


## Provisioner Configuration

The following attributes may be set at the provisioner level:

* `name` - cfengine
* `cfenging_type` - either `community` or `enterprise`, default to `community`
* `cfengine_community_quick_install_url` - url for the cfengine-community quick install script, default to `http://s3.amazonaws.com/cfengine.packages/quick-install-cfengine-community.sh`
* `cfengine_enterprise_quick_install_url` - url for the cfengine-enterprise quick install script, default is `http://s3.amazonaws.com/cfengine.packages/quick-install-cfengine-enterprise.sh`
* `chef_omnibus_url` - url for chef omnibus install, defaults to ``
* `cfengine_policy_server_address` - optional IP address or hostname for policy server, if no address is provided the VM is bootstrapped to itself
* `cf_agent_args` - arguments to pass to cf-agent on provisioning, defaults to `-KI`
* `cfengine_files` - specifies a directory that will be copied into  `/var/cfengine/` on the VM, defaults to `test/cfengine_files`

Additionally you may set the `run_list` attribute at the suite level to run a specific file.
