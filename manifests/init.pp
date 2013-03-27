class physical {

  package { ['irqbalance', 'lm-sensors', 'dmidecode']:
    ensure => installed,
  }

  if $::has_infiniband == 'true' {

    include physical::infiniband
  }

  if $::has_ipmi == 'true' {

    include physical::ipmi
  }

  if $::productname == 'H8DGT' {

    include physical::powersupply
  }

  include physical::cleanup
}
