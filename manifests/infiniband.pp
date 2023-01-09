class physical::infiniband {

  if $facts['os']['distro']['codename'] == 'precise' {

    package { 'mlx4-dkms':
      ensure => absent,
    }

    package { 'mlnx-en-dkms':
      ensure => present,
    }

    file { '/etc/modprobe.d/mlx4.conf':
      ensure  => absent,
    }

    exec { 'update-initramfs-mlnx':
      command     => '/usr/sbin/update-initramfs -k all -u',
      subscribe   => Package['mlnx-en-dkms'],
      refreshonly => true,
    }
  } else {

    file { '/etc/modprobe.d/mlx4.conf':
      ensure  => present,
      content => 'options mlx4_core port_type_array="2,2"',
    }
  }
}
