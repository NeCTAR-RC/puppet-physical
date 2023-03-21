# Configure smartd for a host
class physical::smart(
  String $ensure         = 'present',
  Optional[Array] $disks = undef
) {

  include physical

  package { 'smartmontools' :
    ensure => 'present'
  }

  # use physical::smart::disks if exists, else fall back to
  # physical::localdisks to define smartd.conf
  if ! $disks {
      $localdisks = $physical::localdisks
  }

  file { '/etc/default/smartmontools':
    ensure  => 'present',
    owner   => root,
    group   => root,
    mode    => '0644',
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
    case $facts['os']['distro']['codename'] {
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
