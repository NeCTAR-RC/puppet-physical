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
    key        => '34A9CF8E',
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
    key        => '57E5E96D',
    key_server => 'pgp.mit.edu',
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
    key        => '34D8786F',
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
