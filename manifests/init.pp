# Things for physical hosts
class physical($edac_check=true) {

  # Set up repositories
  class { 'physical::repo':
    stage => setup,
  }

  # Packages
  class { 'physical::package': }

  # Machine Check Exception Log
  if $::lsbdistcodename == 'trusty' {
    if $::processor0 =~ /Intel/ {
      # mcelog doens't work for AMD in Trusty
      class { 'physical::mcelog': }
    }
  } else {
    class { 'physical::mcelog': }
  }

  if $edac_check {
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
  }

  case $::manufacturer {

    'HP' :         { include physical::hp }
    'Dell Inc.' :  {
        case $::productname {
            'PowerEdge R630': {
                class { 'physical::dell':
                    openmanage_check_args => '--no-storage -b bp=0'
                }
            }
            default: { include physical::dell }
        }
    }
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
