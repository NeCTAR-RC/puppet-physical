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

  if $::http_proxy and str2bool($::rfc1918_gateway) {
    $key_options = "http-proxy=${::http_proxy}"
  }
  else {
    $key_options = false
  }

  apt::key { 'hwraid':
    id      => '0073C11919A641464163F7116005210E23B3D3B4',
    server  => 'pgp.mit.edu',
    options => $key_options
  }

  apt::source { 'hwraid':
    location    => 'http://hwraid.le-vert.net/ubuntu',
    release     => 'precise',
    repos       => 'main',
  }
}

class physical::repo::hp {

  if $::http_proxy and str2bool($::rfc1918_gateway) {
    $key_options = "http-proxy=${::http_proxy}"
  }
  else {
    $key_options = false
  }

  apt::key { 'hp':
    id      => '882F7199B20F94BD7E3E690EFADD8D64B1275EA3',
    server  => 'pgp.mit.edu',
    options => $key_options
  }

  apt::source { 'hp':
    location    => 'http://downloads.linux.hpe.com/SDR/downloads/MCP/ubuntu',
    release     => "${::lsbdistcodename}/current",
    repos       => 'non-free',
  }
}

class physical::repo::dell {

  if $::http_proxy and str2bool($::rfc1918_gateway) {
    $key_options = "http-proxy=${::http_proxy}"
  }
  else {
    $key_options = false
  }

  apt::key { 'dell':
    id      => '42550ABD1E80D7C1BC0BAD851285491434D8786F',
    server  => 'pgp.mit.edu',
    options => $key_options
  }

  apt::source { 'dell':
    location => 'http://linux.dell.com/repo/community/ubuntu',
    release  => $::lsbdistcodename,
    repos    => 'openmanage',
  }
}

class physical::repo::supermicro {

}
