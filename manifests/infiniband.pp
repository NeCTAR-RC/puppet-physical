class physical::infiniband {

  file { '/etc/modprobe.d/mlx4.conf':
    ensure  => absent,
  }

  package { 'mlx4-dkms':
    ensure => absent,
  }

  package { 'mlx4-en-dkms':
    ensure => present,
  }

  exec { 'update-initramfs-mlx':
    command     => '/usr/sbin/update-initramfs -k all -u',
    subscribe   => Package['mlnx4-en-dkms'],
    refreshonly => true,
  }
}
