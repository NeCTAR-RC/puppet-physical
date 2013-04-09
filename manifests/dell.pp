class physical::dell {

  package { 'srvadmin-base':
    ensure => present,
  }

  file { '/usr/local/lib/nagios/plugins/check_openmanage':
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/physical/check_openmanage',
  }

  file { '/opt/dell/srvadmin/var/log/openmanage/omcmdlog.xml':
    ensure  => 'link',
    target  => '/var/log/omdell.xml',
    owner   => nagios,
    group   => nagios,
    require => Package['srvadmin-base'],
  }

  file { '/var/log/omdell.xml':
    ensure => present,
    owner  => nagios,
    group  => nagios,
    mode   => '0640'
  }

  service { 'dataeng':
    ensure  => 'running',
    enable  => 'true',
    require => Package['srvadmin-base'],
  }

  nagios::nrpe::service { 'check_openmanage':
    check_command => '/usr/local/lib/nagios/plugins/check_openmanage --no-storage',
    nrpe_command  => 'check_nrpe_slow_1arg'
  }
}
