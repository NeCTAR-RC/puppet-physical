class physical::mcelog (
  $mcelog_check_args='',
){

  File {
    owner   => root,
    group   => root,
    require => Package['mcelog'],
  }


  package { 'mcelog':
    ensure => installed,
  }

  service { 'mcelog':
    ensure  => running,
    enable  => true,
    require => Package['mcelog'],
  }

  file { '/etc/mcelog/mcelog.conf':
    mode   => '0644',
    source => 'puppet:///modules/physical/mcelog.conf',
    notify => Service['mcelog'],
  }

  file { ['/etc/mcelog/cache-error-trigger.local', '/etc/mcelog/dimm-error-trigger.local',
          '/etc/mcelog/page-error-trigger.local', '/etc/mcelog/socket-memory-error-trigger.local']:
    mode    => '0755',
    source  => 'puppet:///modules/physical/mcelog_email_trigger',
    notify  => Service['mcelog'],
  }

  file { '/usr/local/lib/nagios/plugins/check_mcelog':
    mode    => '0755',
    source  => 'puppet:///modules/physical/check_mcelog',
  }

  nagios::nrpe::service { 'check_mcelog':
    check_command => "/usr/local/lib/nagios/plugins/check_mcelog $mcelog_check_args",
  }
}
