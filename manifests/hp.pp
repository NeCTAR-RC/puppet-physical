class physical::hp {

  file { '/etc/sudoers.d/nagios_hp':
    owner   => root,
    group   => root,
    mode    => '0440',
    source  => 'puppet:///modules/physical/sudoers_nagios_hp',
  }

  if $::broken_hp == 'true' {

    package { ['hp-health', 'hponcfg']:
      ensure => absent,
    }

  } else {

    package { ['hp-health', 'hponcfg']:
      ensure => present,
    }

    service { 'hp-health':
      ensure => running,
      enable => true,
    }

    nagios::nrpe::service { 'check_hp_hardware':
      check_command => '/usr/local/lib/nagios/plugins/check_hpasm --ignore-dimms';
    }
  }

  if $::hp_raid == 'true' {

    package { ['hpacucli']:
      ensure => installed,
    }

    nagios::nrpe::service { 'check_hp_raid':
      check_command => '/usr/local/lib/nagios/plugins/check_cciss -s',
    }
  }

  file { '/usr/local/lib/nagios/plugins/check_hpasm':
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/physical/check_hpasm',
  }

  file {'/usr/local/lib/nagios/plugins/check_cciss':
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/physical/check_cciss',
  }
}
