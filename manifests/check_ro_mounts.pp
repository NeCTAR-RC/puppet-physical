# Check if a server has read only filesystems as cheap proxy to disk failure
class physical::check_ro_mounts($ensure='present', $extra_options=undef) {

  file { '/usr/local/lib/nagios/plugins/check_ro_mounts':
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/physical/check_ro_mounts',
  }

  nagios::nrpe::service  { 'check_ro_mounts':
    check_command => '/usr/local/lib/nagios/plugins/check_ro_mounts -X sysfs -X tmpfs -X cgroup' $extra_options,
    nrpe_command  => 'check_ro_mounts',
  }

}
