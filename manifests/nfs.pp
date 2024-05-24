class physical::nfs {

  file { '/etc/sudoers.d/nagios_nfs':
    owner  => root,
    group  => root,
    mode   => '0440',
    source => 'puppet:///modules/physical/sudoers_nagios_nfs',
  }

  file { '/usr/lib/nagios/plugins/check_nfs.py':
    owner  => root,
    group  => root,
    mode   => '0750',
    source => 'puppet:///modules/physical/check_nfs.py',
  }

  nagios::nrpe::service { 'check_nfs_stat':
    check_command => 'sudo /usr/lib/nagios/plugins/check_nfs.py -a',
  }
}
