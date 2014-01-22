class physical::lvm {

  package { 'lvm2':
    ensure => installed,
  }

  $localdisks = hiera('physical::localdisks')

  file { '/etc/lvm/lvm.conf':
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('physical/lvm.conf.erb'),
    require => Package['lvm2'],
  }

  exec { 'lvmdiskscan':
    command     => '/sbin/lvmdiskscan >/dev/null',
    subscribe   => File['/etc/lvm/lvm.conf'],
    refreshonly => true,
    require     => Package['lvm2'],
  }
}
