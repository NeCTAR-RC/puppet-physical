# Mellanox ConnectX (mlx4) infiniband configuration
class physical::infiniband {
  file { '/etc/modprobe.d/mlx4.conf':
    ensure  => present,
    content => 'options mlx4_core port_type_array="2,2"',
  }
}
