class physical::hp {

  file { '/etc/sudoers.d/nagios_hp':
    owner   => root,
    group   => root,
    mode    => '0440',
    source  => 'puppet:///modules/physical/sudoers_nagios_hp',
  }

  if str2bool($::broken_hp) {

    package { ['hp-health', 'hponcfg', 'hpacucli']:
      ensure => absent,
    }

  } else {

    package { ['hp-health', 'hponcfg', 'hpacucli']:
      ensure  => present,
    }

    nagios::nrpe::service { 'check_hp_hardware':
      check_command => '/usr/lib/nagios/plugins/check_hpasm --ignore-dimms';
    }
  }

  if str2bool($::hp_raid) {

    nagios::nrpe::service { 'check_hp_raid':
      check_command => '/usr/local/lib/nagios/plugins/check_cciss -s',
    }
  }

  file { '/usr/local/lib/nagios/plugins/check_hpasm':
    ensure => absent,
  }

  file {'/usr/local/lib/nagios/plugins/check_cciss':
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/physical/check_cciss',
  }
}
