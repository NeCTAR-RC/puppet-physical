class physical::ipmi ($user = 'root', $password, $type = 'dhcp', $gateway, $netmask='255.255.255.0') {

  $ipmi_pkgs = ['ipmitool', 'freeipmi-tools', 'bind9-host']

  package { $ipmi_pkgs :
    ensure => present,
  }

  puppet::kern_module { 'ipmi_si': ensure => present }
  puppet::kern_module { 'ipmi_devintf': ensure => present }

  file { '/etc/init/ttyS1.conf':
    ensure => present,
    source => 'puppet:///modules/physical/ttyS1.conf',
    notify => Service[ttyS1],
  }

  service { 'ttyS1':
    ensure   => running,
    enable   => true,
    provider => upstart,
  }

  file { '/etc/sudoers.d/nagios_ipmi':
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    source  => 'puppet:///modules/physical/sudoers_nagios_ipmi',
  }

  file { '/usr/local/lib/nagios/plugins/check_ipmi_sensor':
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/physical/check_ipmi_sensor',
  }

  nagios::nrpe::service { 'check_ipmi_sensor':
     check_command => '/usr/local/lib/nagios/plugins/check_ipmi_sensor -H localhost -x 1344';
  }

  if $type == 'dhcp' {

    exec { 'ipmi_set_dhcp' :
      command => '/usr/bin/ipmitool lan set 1 ipsrc dhcp',
      onlyif  => '/usr/bin/test $(ipmitool lan print 1 | grep \'IP Address Source\' | cut -f 2 -d : | grep -c DHCP) -eq 0',
    }
  }

  if ($type == 'static') and ($::ipmi_dns_lookup != '' ) {

   $lookup = $::ipmi_dns_lookup

   exec { 'ipmi_set_static' :
      command => '/usr/bin/ipmitool lan set 1 ipsrc static',
      onlyif  => '/usr/bin/test $(ipmitool lan print 1 | grep \'IP Address Source\' | cut -f 2 -d : | grep -c DHCP) -eq 1',
      notify  => [Exec[ipmi_set_ipaddr], Exec[ipmi_set_defgw], Exec[ipmi_set_netmask]],
    }

    exec { 'ipmi_set_ipaddr' :
      command => "/usr/bin/ipmitool lan set 1 ipaddr ${lookup}",
      onlyif  => "/usr/bin/test \"$(ipmitool lan print 1 | grep 'IP Address  ' | sed -e 's/.* : //g')\" != \"${lookup}\"",
    }

    exec { 'ipmi_set_defgw' :
      command => "/usr/bin/ipmitool lan set 1 defgw ipaddr ${gateway}",
      onlyif  => "/usr/bin/test \"$(ipmitool lan print 1 | grep 'Default Gateway IP' | sed -e 's/.* : //g')\" != \"${gateway}\"",
    }

    exec { 'ipmi_set_netmask' :
      command => "/usr/bin/ipmitool lan set 1 netmask ${netmask}",
      onlyif  => "/usr/bin/test \"$(ipmitool lan print 1 | grep 'Subnet Mask' | sed -e 's/.* : //g')\" != \"${netmask}\"",
    }
  }

  if $user != "ADMIN" {

    exec { 'ipmi_reset_default_name' :
      command => "/usr/bin/ipmitool user set name 2 ADMIN",
      unless  => "/usr/bin/test \"$(ipmitool user list 1 | grep '^2' | awk '{print \$2}')\" == \"ADMIN\"",
      notify  => Exec[ipmi_user_add],
    }

    exec { 'ipmi_user_add' :
      command => "/usr/bin/ipmitool user set name 3 ${user}",
      unless  => "/usr/bin/test \"$(ipmitool user list 1 | grep '^3' | awk '{print \$2}')\" == \"${user}\"",
      notify  => [Exec[ipmi_user_enable],Exec[ipmi_user_disable_default]],
    }

    exec { 'ipmi_user_enable' :
      command     => '/usr/bin/ipmitool user enable 3',
      refreshonly => true,
      notify      => [Exec[ipmi_user_priv],Exec[ipmi_user_setpw],Exec[ipmi_user_enable_sol]],
    }

    exec { 'ipmi_user_priv' :
      command => '/usr/bin/ipmitool user priv 3 4 1',
      unless  => "/usr/bin/test \"$(ipmitool user list 1 | grep '^3' | awk '{print \$6}')\" == \"ADMINISTRATOR\""
    }

    exec { 'ipmi_user_disable_default' :
      command     => '/usr/bin/ipmitool user disable 2',
      refreshonly => true,
    }

    exec { 'ipmi_user_setpw' :
      command     => "/usr/bin/ipmitool user set password 3 \'${password}\'",
      refreshonly => true,
    }

    exec { 'ipmi_user_enable_sol' :
      command     => '/usr/bin/ipmitool sol payload enable 1 3',
      refreshonly => true,
    }

    # For Dell, we need to give iDRAC privileges to the user
    if $ipmi_manufacturer == "DELL Inc" {
    # TODO

    # $reservation_id = ipmitool raw 0x2e 0x01 0xa2 0x02 0x00 | cut -d " " -f 5
    # if ("ipmitool raw 0x2e 0x02 0xa2 0x02 0x00 0x$reservation_id 0x04 0x$user_id 0x00 0x00 0xFF" != " ff 01 00 00") {
    #   $reservation_id = ipmitool raw 0x2e 0x01 0xa2 0x02 0x00 | cut -d " " -f 5
    #   ipmitool raw 0x2e 0x03 0xa2 0x02 0x00 0x$reservation_id 0x04 0x$user_id 0x00 0x00 0x01 0x09 0x00 0x01 0x01 0x00 0xff 0x01 0x00 0x00
    # }

    }

  } else {

    exec { 'ipmi_reset_default_name' :
      command => "/usr/bin/ipmitool user set name 2 ADMIN",
      unless  => "/usr/bin/test \"$(ipmitool user list 1 | grep '^2' | awk '{print \$2}')\" == \"ADMIN\"",
      notify  => Exec[ipmi_user_enable],
    }

    exec { 'ipmi_user_enable' :
      command     => '/usr/bin/ipmitool user enable 2',
      refreshonly => true,
      notify      => [Exec[ipmi_user_priv],Exec[ipmi_user_setpw],Exec[ipmi_user_enable_sol]],
    }

    exec { 'ipmi_user_priv' :
      command => '/usr/bin/ipmitool user priv 2 4 1',
      unless  => "/usr/bin/test \"$(ipmitool user list 1 | grep '^2' | awk '{print \$6}')\" == \"ADMINISTRATOR\""
    }

    exec { 'ipmi_user_setpw' :
      command     => "/usr/bin/ipmitool user set password 2 \'${password}\'",
      refreshonly => true,
    }

    exec { 'ipmi_user_enable_sol' :
      command     => '/usr/bin/ipmitool sol payload enable 1 2',
      refreshonly => true,
    }
  }
}
