class physical::packages {

  package { ['irqbalance', 'lm-sensors', 'dmidecode', 'binutils', 'edac-utils', 'mcelog']:
    ensure => installed,
  }

}
