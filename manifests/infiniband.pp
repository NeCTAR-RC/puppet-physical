class physical::infiniband {

  file { '/etc/modprobe.d/mlx4.conf':
    ensure  => present,
    content => 'install mlx4_core /sbin/modprobe --ignore-install mlx4_core; /sbin/modprobe mlx4_en',
  }

  package { 'mlx4-dkms':
    ensure => present,
  }

  exec { 'update-initramfs-mlx' :
    command     => '/usr/sbin/update-initramfs -k all -u',
    subscribe   => [File['/etc/modprobe.d/mlx4.conf'], Package['mlx4-dkms']],
    refreshonly => true,
  }
}
