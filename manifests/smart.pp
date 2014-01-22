class physical::smart($ensure='present') {

  package { 'smartmontools' :
    ensure => $ensure,
  }

  file { '/etc/default/smartmontools':
    ensure => $ensure,
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/physical/smartmontools',
  }

  file { '/etc/smartd.conf':
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('physical/smartd.conf.erb'),
    notify  => Service[smartd],
  }

  if $ensure == 'present' {
    service { 'smartd':
      ensure    => running,
      require   => Package['smartmontools'],
      subscribe => File['/etc/default/smartmontools'],
    }
  }
}
