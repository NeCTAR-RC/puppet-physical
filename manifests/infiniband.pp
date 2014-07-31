class physical::infiniband {

  if $::lsbdistcodename == 'precise' {
  
    file { '/etc/modprobe.d/mlx4.conf':
      ensure  => absent,
    }
    
    package { 'mlx4-dkms':
      ensure => absent,
    }
    
    package { 'mlnx-en-dkms':
      ensure => present,
    }
    
    exec { 'update-initramfs-mlnx':
      command     => '/usr/sbin/update-initramfs -k all -u',
      subscribe   => Package['mlnx-en-dkms'],
      refreshonly => true,
    }
  }
}
