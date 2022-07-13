# Configure smart nagios checks for a host
class physical::smart_nagios(
  $enabled=true
  ) {

    $ensure_files=$enabled? {
      true  => 'present',
      false => 'absent',
    }

    file {'/usr/local/lib/nagios/plugins/check_smart.pl':
      ensure  => $ensure_files,
      source  => 'puppet:///modules/physical/check_smart.pl',
      owner   => root,
      group   => root,
      mode    => '0775',
      require => Package['smartmontools'],
    }

    file {'/usr/local/lib/nagios/plugins/check_smart_wrapper.py':
      ensure  => $ensure_files,
      source  => 'puppet:///modules/physical/check_smart_wrapper.py',
      owner   => root,
      group   => root,
      mode    => '0775',
      require => File['/usr/local/lib/nagios/plugins/check_smart.pl'],
    }

    file { '/etc/sudoers.d/smart_nagios_check':
      ensure  => $ensure_files,
      content => "nagios ALL = NOPASSWD: /usr/sbin/smartctl\n",
      owner   => root,
      group   => root,
      mode    => '0440',
    }

  if $enabled {
    nagios::nrpe::service {
      'check_smart':
        check_command => '/usr/local/lib/nagios/plugins/check_smart_wrapper.py',
        require       => File['/usr/local/lib/nagios/plugins/check_smart_wrapper.py'],
    }
  }

}
