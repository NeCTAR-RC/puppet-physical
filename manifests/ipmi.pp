class physical::ipmi ($user = 'root', $password, $type = 'dhcp', $gateway, $netmask='255.255.255.0') {

  $ipmi_pkgs = ['ipmitool', 'freeipmi-tools', 'bind9-host']

  package { $ipmi_pkgs :
    ensure => present,
  }

  puppet::kern_module { 'ipmi_si': ensure => present }
  puppet::kern_module { 'ipmi_devintf': ensure => present }

  file { '/usr/lib/nagios/plugins/check_ipmi_sensor.pl':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => 'puppet:///modules/physical/check_ipmi_sensor.pl',
  }

  file { '/etc/sudoers.d/nagios_ipmi':
    owner   => 'root',
    group   => 'root',
    mode    => 440,
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

  if $chassis_pwmon == 'yes' {

    file{ '/usr/local/lib/nagios/plugins/check_powersupply':
      owner   => root,
      group   => root,
      mode    => '0755',
      source  => 'puppet:///modules/physical/check_powersupply',
    }
    # only check power supply every 2 hours & adding 60 seconds timeout for plugins since=
    nagios::nrpe::service  { 'check_ps':
      check_command => '/usr/local/lib/nagios/plugins/check_ps',
      nrpe_command  => 'check_nrpe_slow',
    }
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

  exec { 'ipmi_add_user' :
    command => "/usr/bin/ipmitool user set name 2 ${user}",
    unless  => "/usr/bin/test \"$(ipmitool user list 1 | grep '^2' | awk '{print \$2}' | grep ${user})\" == \"${user}\"",
    notify  => Exec[ipmi_user_enable],
  }

  exec { 'ipmi_user_enable' :
    command     => '/usr/bin/ipmitool user enable 2',
    refreshonly => true,
    notify      => Exec[ipmi_set_pw],
  }

  exec { 'ipmi_set_pw' :
    command     => "/usr/bin/ipmitool user set password 2 \'${password}\'",
    refreshonly => true,
  }
}
