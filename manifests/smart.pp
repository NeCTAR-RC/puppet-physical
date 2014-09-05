class physical::smart($ensure='present') {

  package { 'smartmontools' :
    ensure => $ensure,
  }

  $localdisks = hiera('physical::localdisks')

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
  }

  if $ensure == 'present' {
    case $::lsbdistcodename {
      precise : { $smartservice = 'smartd' }
      default : { $smartservice = 'smartmontools' }
    }
    service { $smartservice :
      ensure    => running,
      require   => Package['smartmontools'],
      subscribe => [ File['/etc/default/smartmontools'],
                     File['/etc/smartd.conf'],],
    }
  }
}
