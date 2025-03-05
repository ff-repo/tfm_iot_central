# frozen_string_literal: true

module OsHelper
  def host_info
    memory = `cat /proc/meminfo | grep MemTotal` rescue nil # only linux
    resources = {
      cpu: {
        size: OS.cpu_count
      },
      memory: memory
    }
    extra_os = OS.parse_os_release rescue nil

    {
      ruby: {
        version: "#{RbConfig::CONFIG['MAJOR']}.#{RbConfig::CONFIG['MINOR']}.#{RbConfig::CONFIG['TEENY']}",
        so_name: "#{RbConfig::CONFIG['RUBY_SO_NAME']}"
      },
      system: {
        unique_identifier: MACHINE_ID,
        resources: resources,
        os: YAML.load(OS.report),
        extra_os: extra_os
      }
    }
  end

end