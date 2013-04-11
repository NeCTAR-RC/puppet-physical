class physical::hp {


  file { '/etc/sudoers.d/nagios_hp':
    owner   => root,
    group   => root,
    mode    => '0440',
    source  => 'puppet:///modules/nagios/sudoers_nagios_hp',
  }

  package { ['hp-health', 'hponcfg', 'binutils']:
    ensure => installed,
  }

  service { 'hp-health':
    ensure => running,
    enable => true,
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

  # FIXME use a fact to determine host type so it is portable?
  if $hostname =~ /^qh2-rc[s|p]\d+$/ {

    nagios::nrpe::service { 'check_hp_hardware':
      check_command => '/usr/local/lib/nagios/plugins/check_hpasm --ignore-dimms';
    }
  }

  if $hostname =~ /^np-rc[s|p]\d+$/ {

    nagios::nrpe::service { 'check_cciss':
      check_command => '/usr/local/lib/nagios/plugins/check_cciss -s',
    }
  }
}
