class physical::powersupply {

  if $h8dgt_ps1 == 'true' and $h8dgt_pm_ps1 == 'true' {

    # only check power supply every 2 hours with a 20 second timeout
    nagios::nrpe::service  { 'check_powersupply1':
      check_command => '/usr/local/lib/nagios/plugins/check_powersupply 1',
      nrpe_command  => 'check_nrpe_slow_1arg',
    }

  }

  if $h8dgt_ps2 == 'true' and $h8dgt_pm_ps2 == 'true' {

    # only check power supply every 2 hours with a 20 second timeout
    nagios::nrpe::service  { 'check_powersupply2':
      check_command => '/usr/local/lib/nagios/plugins/check_powersupply 2',
      nrpe_command  => 'check_nrpe_slow_1arg',
    }

  }

  if $h8dgt_ps3 == 'true' and $h8dgt_pm_ps2 == 'true' {

    # only check power supply every 2 hours with a 20 second timeout
    nagios::nrpe::service  { 'check_powersupply3':
      check_command => '/usr/local/lib/nagios/plugins/check_powersupply 3',
      nrpe_command  => 'check_nrpe_slow_1arg',
    }
  }

  file { '/usr/local/lib/nagios/plugins/check_powersupply':
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/physical/check_powersupply',
  }

}
