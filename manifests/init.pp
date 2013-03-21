class physical {

  package { ['smartmontools', 'hddtemp'] :
    ensure => installed,
  }

  # dev kit doesn't have good smart capabilities
  if $::environment != 'development' {
    file { '/etc/default/smartmontools':
      owner  => root,
      group  => root,
      mode   => 0644,
      source => 'puppet:///modules/physical/smartmontools',
     notify => Service['smartd'],
    }

    service { 'smartd':
      ensure  => running,
      require => Package['smartmontools'],
      subscribe => File['/etc/default/smartmontools'],
    }

    file { '/etc/default/hddtemp':
      owner  => root,
      group  => root,
      mode   => 0644,
      source => 'puppet:///modules/physical/hddtemp',
      notify => Service['hddtemp'],
    }

    service { 'hddtemp':
      ensure  => running,
      require => Package['hddtemp'],
      subscribe => File['/etc/default/hddtemp'],
    }
  }

  package { ['irqbalance', 'ipmitool', 'lm-sensors', 'freeipmi-tools']:
    ensure => installed,
  }

  puppet::kern_module { 'ipmi_si': ensure => present }
  puppet::kern_module { 'ipmi_devintf': ensure => present }

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

  if $::infiniband == 'true' {

    file { '/etc/modprobe.d/mlx4.conf':
      ensure  => present,
      content => 'install mlx4_core /sbin/modprobe --ignore-install mlx4_core; /sbin/modprobe mlx4_en',
    }

   exec { 'update-initramfs-mlx' :
     command     => '/usr/sbin/update-initramfs -k all -u',
     subscribe   => File['/etc/modprobe.d/mlx4.conf'],
     refreshonly => true,
   }
  }
}
