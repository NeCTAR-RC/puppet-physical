class physical::cleanup {

  # clean up old files
  file { '/usr/local/lib/nagios/plugins/check_ps':
    ensure => absent,
  }

  file { '/etc/nagios/nrpe.d/check_ps.cfg':
    ensure => absent,
  }

  file { '/etc/sudoers.d/sudoers_nagios':
    ensure => absent,
  }

  file { '/usr/local/sbin/bmc_change_static.sh':
    ensure => absent,
  }

  file { '/usr/local/sbin/bmc_change_dhcp.sh':
    ensure => absent,
  }

  file { '/usr/local/sbin/bmc_change_password.sh':
    ensure => absent,
  }

  file { '/usr/local/lib/nagios/plugins/check_linux_raid':
    ensure => absent,
  }

  file{ '/usr/local/lib/nagios/plugins/check_md_raid':
    ensure => absent,
  }

  file { '/usr/lib/nagios/plugins/check_ipmi_sensor.pl':
    ensure => absent,
  }

  file { '/usr/local/sbin/gen-nfs-stats.sh':
    ensure => absent,
  }

  cron { nfsstat:
    ensure => absent,
  }

  cron { netstat:
    ensure => absent,
  }

  file { '/usr/lib/ruby/1.8/facter/supermicro_ps.rb':
    ensure => absent,
  }

  file { '/usr/local/etc/chassis_info':
    ensure => absent,
  }

  file { '/etc/apt/sources.list.d/hp.mcp.list':
    ensure => absent,
  }
}
