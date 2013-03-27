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
}
