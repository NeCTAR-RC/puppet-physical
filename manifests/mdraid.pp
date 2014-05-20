class physical::mdraid {

  nagios::nrpe::service { 'check_md_raid':
    check_command => '/usr/lib/nagios/plugins/check_raid -p lsscsi,mdstat,megacli';
  }

}
