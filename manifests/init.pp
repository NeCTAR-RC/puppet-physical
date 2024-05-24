# Things for physical hosts
class physical(
  Boolean $edac_check = true,
  Array $localdisks   = [],
) {

  # Set up repositories
  class { 'physical::repo': }

  # Packages
  class { 'physical::package':
    require => Class['physical::repo'],
  }

  # Machine Check Exception Log
  # Note: Bionic removes MCELog https://bugs.launchpad.net/ubuntu/+source/mcelog/+bug/1752251
  if $facts['facts']['processors']['models'][0] =~ /Intel/ and versioncmp($facts['os']['release']['full'], '18.04') < 0  {
    # mcelog doens't work for AMD, uses edac_mce_amd instead
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

  case $facts['dmi']['manufacturer'] {

    'HP' :         { include physical::hp }
    'Dell Inc.' :  {
        case $facts['dmi']['product']['name'] {
            'PowerEdge R630': {
                class { 'physical::dell':
                    openmanage_check_args => '--no-storage -b bp=0'
                }
            }
            default: { include physical::dell }
        }
    }
    'Supermicro' : { include physical::supermicro }
    default: {}

  }

  if $facts['mdadm_devices'] != '' {
    include physical::mdraid
  }

  if str2bool($facts['has_nfs_mounts']) {
    include physical::nfs
  }

}
