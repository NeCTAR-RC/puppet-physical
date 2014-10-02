class physical::smart($ensure='present') {

  package { 'smartmontools' :
    ensure => 'present'
  }

  $localdisks = hiera('physical::localdisks')

  file { '/etc/default/smartmontools':
    ensure => 'present',
    owner  => root,
    group  => root,
    mode   => '0644',
    content => template('physical/etc-default-smartmontools.erb'),
  }

  file { '/etc/smartd.conf':
    ensure  => 'present',
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
