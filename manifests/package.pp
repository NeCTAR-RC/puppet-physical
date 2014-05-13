class physical::package {

  package { ['irqbalance', 'lm-sensors', 'dmidecode', 'binutils', 'edac-utils']:
    ensure => installed,
  }
}
