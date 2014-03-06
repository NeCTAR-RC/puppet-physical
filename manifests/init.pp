class physical {

  anchor {'physical::begin': }
  anchor {'physical::end': }

  # Set up repositories
  class { 'physical::repos': }

  # Packages
  class { 'physical::packages': }

  # Ensure that we set up the repositories before trying to install
  # the packages
  Anchor['physical::begin']
  -> Class['physical::repos']
  -> Class['physical::packages']
  -> Anchor['physical::end']

  file { '/usr/local/lib/nagios/plugins/check_edac':
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/physical/check_edac',
    require => Package['edac-utils'],
  }

  nagios::nrpe::service { 'check_edac':
    check_command => '/usr/local/lib/nagios/plugins/check_edac';
  }

  file { '/usr/local/lib/nagios/plugins/check_mcelog':
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/physical/check_mcelog',
    require => Package['mcelog'],
  }

  nagios::nrpe::service { 'check_mcelog':
     check_command => '/usr/local/lib/nagios/plugins/check_mcelog';
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
