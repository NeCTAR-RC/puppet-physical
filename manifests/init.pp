class physical {

  package { ['irqbalance', 'lm-sensors', 'dmidecode']:
    ensure => installed,
  }

  if $::boardproductname == 'H8DGT' {

    file {'/etc/init/ttyS1.conf':
      ensure => present,
      source => 'puppet:///modules/physical/ttyS1.conf',
      notify => Service[ttyS1],
    }

    service { 'ttyS1':
      ensure => running,
      enable => true,
      provider => upstart,
    }
  }

  if $::has_infiniband == 'true' {

    include physical::infiniband
  }

  if $::has_ipmi == 'true' {

    include physical::ipmi
  }
}
