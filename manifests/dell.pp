class physical::dell (
  $openmanage_check_args='--no-storage',
  $openmanage_check_interval='60',
){


  file { '/etc/sudoers.d/nagios_dell':
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    source => 'puppet:///modules/physical/sudoers_nagios_dell',
  }

  package { ['srvadmin-base', 'srvadmin-omcommon', 'srvadmin-omacore', 'libxslt1.1']:
    ensure  => present,
    tag     => 'dell',
    require => Class['apt::update'],
  }

  file { '/usr/local/lib/nagios/plugins/check_openmanage':
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/physical/check_openmanage',
  }

  file { '/opt/dell/srvadmin/var/log/openmanage/omcmdlog.xml':
    ensure  => link,
    target  => '/var/log/omdell.xml',
    owner   => 'nagios',
    group   => 'nagios',
    require => Package['srvadmin-base'],
  }

  file { '/var/log/omdell.xml':
    ensure => present,
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '1664'
  }

  service { ['dsm_sa_datamgrd.service', 'dsm_sa_eventmgrd.service', ]:
    ensure  => 'running',
    enable  => true,
    require => [Package['srvadmin-base'], Package['srvadmin-omacore']],
  }

  nagios::nrpe::service { 'check_openmanage':
    check_command  => "/usr/bin/sudo /usr/local/lib/nagios/plugins/check_openmanage ${openmanage_check_args}",
    nrpe_command   => 'check_nrpe_slow_1arg',
    check_interval => $openmanage_check_interval
  }
}
