class physical {

  package { ['irqbalance', 'lm-sensors', 'dmidecode', 'binutils']:
    ensure => installed,
  }

  case $::manufacturer {

    'HP' :         { include physical::hp }
    'Dell Inc.' :  { include physical::dell }
    'Supermicro' : { include physical::supermicro }

  }

  if $::mdadm_devices != '' {

    include physical::mdraid
  }

  if $::has_nfs_mounts == 'true' {

    include physical::nfs
  }

  puppet::kern_module { 'microcode': ensure => present }

  if $::processor0 =~ /Intel/ {

    package{ 'intel-microcode':
      ensure => installed,
    }
  }

}
