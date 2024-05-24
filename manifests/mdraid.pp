class physical::mdraid {

  nagios::nrpe::service { 'check_md_raid':
    check_command => '/usr/lib/nagios/plugins/check_raid -p lsscsi,mdstat,megacli --resync=OK';
  }

  file { '/etc/sudoers.d/nagios_raid':
    owner  => root,
    group  => root,
    mode   => '0440',
    source => 'puppet:///modules/physical/sudoers_nagios_raid',
  }
}
