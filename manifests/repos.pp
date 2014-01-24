class physical::repos {

  case $::manufacturer {

    'HP' :         { include physical::repos::hp }
    'Dell Inc.' :  { include physical::repos::dell }
    'Supermicro' : { include physical::repos::supermicro }

  }

  include physical::repos::hwraid

}

class physical::repos::hwraid {

  if $::rfc1918_gateway == 'true' {
    exec { 'hwraid-apt-key':
     path        => '/usr/bin:/bin:/usr/sbin:/sbin',
     command     => "apt-key adv --keyserver pgp.mit.edu --keyserver-options http-proxy=\"${::http_proxy}\" --recv-keys 34A9CF8E",
     unless      => 'apt-key list | grep 34A9CF8E >/dev/null 2>&1',
    }

  } else {
    apt::key { 'hwraid':
      key        => '34A9CF8E',
      key_server => 'pgp.mit.edu',
    }
  }

  apt::source { 'hwraid':
    location    => 'http://hwraid.le-vert.net/ubuntu',
    release     => 'precise',
    repos       => 'main',
    key         => '34A9CF8E',
    include_src => false,
  }
}

class physical::repos::hp {

  if $::rfc1918_gateway == 'true' {
    exec { 'hp-apt-key':
     path        => '/usr/bin:/bin:/usr/sbin:/sbin',
     command     => "apt-key adv --keyserver pgp.mit.edu --keyserver-options http-proxy=\"${::http_proxy}\" --recv-keys 57E5E96D",
     unless      => 'apt-key list | grep 57E5E96D >/dev/null 2>&1',
    }

  } else {
    apt::key { 'hp':
      key        => '57E5E96D',
      key_server => 'pgp.mit.edu',
    }
  }

  apt::source { 'hp':
    location    => 'http://downloads.linux.hp.com/SDR/downloads/MCP/ubuntu',
    release     => 'precise/current',
    repos       => 'non-free',
    key         => '57E5E96D',
    include_src => false,
  }
}

class physical::repos::dell {

  if $::rfc1918_gateway == 'true' {
    exec { 'dell-apt-key':
     path        => '/usr/bin:/bin:/usr/sbin:/sbin',
     command     => "apt-key adv --keyserver pgp.mit.edu --keyserver-options http-proxy=\"${::http_proxy}\" --recv-keys 34D8786F",
     unless      => 'apt-key list | grep 34D8786F >/dev/null 2>&1',
    }

  } else {
    apt::key { 'dell':
      key        => '34D8786F',
      key_server => 'pgp.mit.edu',
    }
  }

  apt::source { 'dell':
    location    => 'http://linux.dell.com/repo/community/deb/latest ',
    release     => '/',
    repos       => '',
    key         => '34D8786F',
    include_src => false,
  }
}

class physical::repos::supermicro {

}
