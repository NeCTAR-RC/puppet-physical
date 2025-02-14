# Sets up IPMI passwords and networking etc.
class physical::ipmi (
  $password,
  $gateway             = undef,
  $user                = 'root',
  $type                = 'dhcp',
  $netmask             = '255.255.255.0',
  $domain              = '',
  $lan_channel         = 1,
  $serial_tty          = '',
  $sensor_ignore_codes = undef,
) inherits physical {

  include kmod
  require stdlib

  if $type == 'static' and $gateway !~ Stdlib::IP::Address::V4 {
    fail('You must provide gateway as an IPv4 address if network type is static')
  }

  $ipmi_pkgs = ['ipmitool', 'freeipmi-tools', 'bind9-host', 'libipc-run-perl']

  package { $ipmi_pkgs :
    ensure => present,
  }

  file { '/etc/default/ipmievd':
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => 'puppet:///modules/physical/ipmievd_default',
    require => Package[$ipmi_pkgs],
  }

  kmod::load {'ipmi_si':}
  kmod::load {'ipmi_devintf':}

  service { 'ipmievd':
    ensure  => running,
    require => File['/etc/default/ipmievd'],
  }

  if $domain != '' {
    file { '/etc/facter/facts.d/ipmi_domain.txt':
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => "ipmi_domain=${domain}",
    }
  }

  if $serial_tty != '' {

    file { "/etc/init/${serial_tty}.conf":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template('physical/ttySX.conf.erb'),
      notify  => Service[$serial_tty],
    }

    service { $serial_tty:
      ensure   => running,
      enable   => true,
      provider => upstart,
    }
  }

  file { '/etc/sudoers.d/nagios_ipmi':
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    source => 'puppet:///modules/physical/sudoers_nagios_ipmi',
  }

  if $sensor_ignore_codes == undef {

    case $facts['dmidecode_product_name'] {
      'PowerEdge R630': {
        $excluded_ipmi_codes = '30,52,82,1344,2684,2751,77,83,57,90,86'
      }
      'PowerEdge R430': {
        $excluded_ipmi_codes = '35,37,56'
      }
      'PowerEdge R640': {
        $excluded_ipmi_codes = '44,48,204'
      }
      default: {
        $excluded_ipmi_codes = '30,52,82,1344,2684,2751,77,83,57,90'
      }
    }
  } else {
    $excluded_ipmi_codes = $sensor_ignore_codes
  }

  case $facts['os']['distro']['codename'] {
    'bionic': {
      $check_command = "/usr/lib/nagios/plugins/check_ipmi_sensor -x ${excluded_ipmi_codes}"
      file { '/usr/local/lib/nagios/plugins/check_ipmi_sensor':
        ensure => absent,
      }
    }
    default: {
      $check_command = "/usr/local/lib/nagios/plugins/check_ipmi_sensor -H localhost -x ${excluded_ipmi_codes}"
      file { '/usr/local/lib/nagios/plugins/check_ipmi_sensor':
        owner   => root,
        group   => root,
        mode    => '0755',
        source  => 'puppet:///modules/physical/check_ipmi_sensor',
        require => Package[$ipmi_pkgs],
      }
    }
  }

  nagios::nrpe::service { 'check_ipmi_sensor':
    nrpe_command  => 'check_nrpe_slow_1arg',
    check_command => $check_command,
  }

  if $facts['ipmi_manufacturer'] == 'DELL Inc' {

    exec { 'ipmi_set_dell_lcd_hostname':
      command => "/usr/bin/ipmitool delloem lcd set mode userdefined ${facts['networking']['hostname']}",
      unless  => "/usr/bin/test \"$(/usr/bin/ipmitool delloem lcd info | grep Text | awk '{print \$2}')\" == \"${facts['networking']['hostname']}\"",
      onlyif  => '/usr/bin/ipmitool delloem lcd info | grep Text',
      require => Package[$ipmi_pkgs],
    }
  }

  if $type == 'dhcp' {

    exec { 'ipmi_set_dhcp' :
      command => "/usr/bin/ipmitool lan set ${lan_channel} ipsrc dhcp",
      onlyif  => "/usr/bin/test $(ipmitool lan print ${lan_channel} | grep 'IP Address Source' | cut -f 2 -d : | grep -c DHCP) -eq 0",
      require => Package[$ipmi_pkgs]
    }
  }

  if ($type == 'static') and ($facts['ipmi_dns_lookup'] != undef) {

    $lookup = $facts['ipmi_dns_lookup']

    exec { 'ipmi_set_static' :
      command => "/usr/bin/ipmitool lan set ${lan_channel} ipsrc static",
      onlyif  => "/usr/bin/test $(ipmitool lan print ${lan_channel} | grep 'IP Address Source' | cut -f 2 -d : | grep -c DHCP) -eq 1",
      notify  => [Exec[ipmi_set_ipaddr], Exec[ipmi_set_defgw], Exec[ipmi_set_netmask]],
      require => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_set_ipaddr' :
      command => "/usr/bin/ipmitool lan set ${lan_channel} ipaddr ${lookup}",
      onlyif  => "/usr/bin/test \"$(ipmitool lan print ${lan_channel} | grep 'IP Address  ' | sed -e 's/.* : //g')\" != \"${lookup}\"",
      require => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_set_defgw' :
      command => "/usr/bin/ipmitool lan set ${lan_channel} defgw ipaddr ${gateway}",
      onlyif  => "/usr/bin/test \"$(ipmitool lan print ${lan_channel} | grep 'Default Gateway IP' | sed -e 's/.* : //g')\" != \"${gateway}\"",
      require => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_set_netmask' :
      command => "/usr/bin/ipmitool lan set ${lan_channel} netmask ${netmask}",
      onlyif  => "/usr/bin/test \"$(ipmitool lan print ${lan_channel} | grep 'Subnet Mask' | sed -e 's/.* : //g')\" != \"${netmask}\"",
      require => Package[$ipmi_pkgs]
    }
  }

  if $user == 'ADMIN' {

    exec { 'ipmi_reset_default_name' :
      command => '/usr/bin/ipmitool user set name 2 ADMIN',
      unless  => "/usr/bin/test \"$(ipmitool user list 1 | grep '^2' | awk '{print \$2}')\" == \"ADMIN\"",
      notify  => [Exec[ipmi_user_priv], Exec[ipmi_user_setpw]],
      require => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_user_priv' :
      command => '/usr/bin/ipmitool user priv 2 4 1',
      unless  => "/usr/bin/test \"$(ipmitool user list 1 | grep '^2' | awk '{print \$6}')\" == \"ADMINISTRATOR\"",
      notify  => [Exec[ipmi_user_enable], Exec[ipmi_user_enable_sol]],
      require => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_user_setpw' :
      command => Sensitive("/usr/bin/ipmitool user set password 2 \'${password}\' 16"),
      unless  => Sensitive("/usr/bin/ipmitool user test 2 16 \'${password}\'"),
      notify  => [Exec[ipmi_user_enable], Exec[ipmi_user_enable_sol]],
      require => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_user_enable' :
      command     => '/usr/bin/ipmitool user enable 2',
      refreshonly => true,
      require     => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_user_enable_sol' :
      command     => '/usr/bin/ipmitool sol payload enable 1 2',
      refreshonly => true,
      require     => Package[$ipmi_pkgs]
    }

    if $facts['ipmi_manufacturer'] == 'DELL Inc' {

      file { '/usr/local/sbin/idrac_user_priv.sh':
        owner  => root,
        group  => root,
        mode   => '0750',
        source => 'puppet:///modules/physical/idrac_user_priv.sh',
      }

      if $facts['idrac_user2_priv'] != 'ff 01 00 00' {

        exec { 'set_idrac_priv':
          command => '/usr/local/sbin/idrac_user_priv.sh 2 3',
          require => [File['/usr/local/sbin/idrac_user_priv.sh'],
                      Package[$ipmi_pkgs]],
        }
      }
    }
  }

  else {

    exec { 'ipmi_reset_default_name' :
      command => '/usr/bin/ipmitool user set name 2 ADMIN',
      unless  => "/usr/bin/test \"$(ipmitool user list 1 | grep '^2' | awk '{print \$2}')\" == \"ADMIN\"",
      notify  => Exec[ipmi_user_add],
      require => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_user_disable_default' :
      command     => '/usr/bin/ipmitool user disable 2',
      refreshonly => true,
      require     => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_user_add' :
      command => "/usr/bin/ipmitool user set name 3 ${user}",
      unless  => "/usr/bin/test \"$(ipmitool user list 1 | grep '^3' | awk '{print \$2}')\" == \"${user}\"",
      notify  => [Exec[ipmi_user_priv], Exec[ipmi_user_setpw]],
      require => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_user_priv' :
      command => '/usr/bin/ipmitool user priv 3 4 1',
      unless  => "/usr/bin/test \"$(ipmitool user list 1 | grep '^3' | awk '{print \$6}')\" == \"ADMINISTRATOR\"",
      notify  => [Exec[ipmi_user_enable], Exec[ipmi_user_enable_sol], Exec[ipmi_user_disable_default], Exec[ipmi_user_channel_setaccess]],
      require => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_user_setpw' :
      command => Sensitive("/usr/bin/ipmitool user set password 3 \'${password}\' 16"),
      unless  => Sensitive("/usr/bin/ipmitool user test 3 16 \'${password}\'"),
      notify  => [Exec[ipmi_user_enable], Exec[ipmi_user_enable_sol], Exec[ipmi_user_disable_default], Exec[ipmi_user_channel_setaccess]],
      require => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_user_enable' :
      command     => '/usr/bin/ipmitool user enable 3',
      refreshonly => true,
      require     => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_user_enable_sol' :
      command     => '/usr/bin/ipmitool sol payload enable 1 3',
      refreshonly => true,
      require     => Package[$ipmi_pkgs]
    }

    exec { 'ipmi_user_channel_setaccess':
      command     => '/usr/bin/ipmitool channel setaccess 1 3 callin=on ipmi=on link=on privilege=4',
      refreshonly => true,
      require     => Package[$ipmi_pkgs]
    }

    if $facts['ipmi_manufacturer'] == 'DELL Inc' {

      file { '/usr/local/sbin/idrac_user_priv.sh':
        owner  => root,
        group  => root,
        mode   => '0750',
        source => 'puppet:///modules/physical/idrac_user_priv.sh',
      }

      if ($facts['idrac_user2_priv'] != '01 00 00 00') or ($facts['idrac_user3_priv'] != 'ff 01 00 00') {

        exec { 'set_idrac_priv':
          command => '/usr/local/sbin/idrac_user_priv.sh 3 3',
          require => [File['/usr/local/sbin/idrac_user_priv.sh'],
                      Package[$ipmi_pkgs]],
        }

        exec { 'remove_idrac_admin_priv':
          command => '/usr/local/sbin/idrac_user_priv.sh 2 1',
          require => [File['/usr/local/sbin/idrac_user_priv.sh'],
                      Package[$ipmi_pkgs]],
        }
      }
    }
  }
}
