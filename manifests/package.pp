class physical::package {

  package { ['irqbalance', 'lm-sensors', 'dmidecode', 'binutils', 'edac-utils', 'mcelog']:
    ensure => installed,
  }

}
