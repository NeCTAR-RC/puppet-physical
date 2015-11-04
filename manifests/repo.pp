class physical::repo {

  case $::manufacturer {
    'HP' :         {
      class {'physical::repo::hp':
        stage => setup,
      }
    }
    'Dell Inc.' :  {
      class {'physical::repo::dell':
        stage => setup,
      }
    }
    'Supermicro' : {
      class {'physical::repo::supermicro':
        stage => setup,
      }
    }
  }
  class {'physical::repo::hwraid':
    stage => setup,
  }

}

class physical::repo::hwraid {

  if $::http_proxy and $::rfc1918_gateway == 'true' {
    $key_options = "http-proxy=${::http_proxy}"
  }
  else {
    $key_options = false
  }

  apt::key { 'hwraid':
    key        => '0073C11919A641464163F7116005210E23B3D3B4',
    key_server => 'pgp.mit.edu',
    key_options => $key_options
  }

  apt::source { 'hwraid':
    location    => 'http://hwraid.le-vert.net/ubuntu',
    release     => 'precise',
    repos       => 'main',
    include_src => false,
  }
}

class physical::repo::hp {

  if $::http_proxy and $::rfc1918_gateway == 'true' {
    $key_options = "http-proxy=${::http_proxy}"
  }
  else {
    $key_options = false
  }

  apt::key { 'hp':
    key         => '882F7199B20F94BD7E3E690EFADD8D64B1275EA3',
    key_server  => 'pgp.mit.edu',
    key_options => $key_options
  }

  apt::source { 'hp':
    location    => 'http://downloads.linux.hp.com/SDR/downloads/MCP/ubuntu',
    release     => "${::lsbdistcodename}/current",
    repos       => 'non-free',
    include_src => false,
  }
}

class physical::repo::dell {

  if $::http_proxy and $::rfc1918_gateway == 'true' {
    $key_options = "http-proxy=${::http_proxy}"
  }
  else {
    $key_options = false
  }

  apt::key { 'dell':
    key        => '42550ABD1E80D7C1BC0BAD851285491434D8786F',
    key_server => 'pgp.mit.edu',
    key_options => $key_options
  }

  apt::source { 'dell':
    location    => 'http://linux.dell.com/repo/community/deb/latest ',
    release     => '/',
    repos       => '',
    include_src => false,
  }
}

class physical::repo::supermicro {

}
