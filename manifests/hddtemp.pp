class physical::hddtemp($ensure='present') {

  package { 'hddtemp' :
    ensure => $ensure,
  }

  file { '/etc/default/hddtemp':
    ensure => $ensure,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/physical/hddtemp',
  }

  if $ensure == 'present' {
    service { 'hddtemp':
      ensure    => running,
      require   => Package['hddtemp'],
      subscribe => File['/etc/default/hddtemp'],
    }
  }
}
