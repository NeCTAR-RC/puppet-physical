class physical {

  # Set up repositories
  class { 'physical::repo':
    stage => setup,
  }

  # Packages
  class { 'physical::package': }

  # Machine Check Exception Log
  class { 'physical::mcelog': }

  file { '/usr/local/lib/nagios/plugins/check_edac':
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/physical/check_edac',
    require => Package['edac-utils'],
  }

  nagios::nrpe::service { 'check_edac':
    check_command => '/usr/local/lib/nagios/plugins/check_edac';
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

  # on trusty this is a builtin module
  if $::lsbdistcodename == 'precise' {

    puppet::kern_module { 'microcode': ensure => present }

    if $::processor0 =~ /Intel/ {

      package{ 'intel-microcode':
        ensure => installed,
      }

    }

  }
}
