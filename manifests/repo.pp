class physical::repo {

  case $::manufacturer {

    'HP' :         { include physical::repo::hp }
    'Dell Inc.' :  { include physical::repo::dell }
    'Supermicro' : { include physical::repo::supermicro }

  }

  include physical::repo::hwraid

}

class physical::repo::hwraid {

  apt::key { 'hwraid':
    key        => '34A9CF8E',
    key_server => 'pgp.mit.edu',
  }

  apt::source { 'hwraid':
    location    => 'http://hwraid.le-vert.net/ubuntu',
    release     => 'precise',
    repos       => 'main',
    key         => '34A9CF8E',
    include_src => false,
  }
}

class physical::repo::hp {

  apt::key { 'hp':
    key        => '57E5E96D',
    key_server => 'pgp.mit.edu',
  }

  apt::source { 'hp':
    location    => 'http://downloads.linux.hp.com/SDR/downloads/MCP/ubuntu',
    release     => 'precise/current',
    repos       => 'non-free',
    key         => '57E5E96D',
    include_src => false,
  }
}

class physical::repo::dell {

  apt::key { 'dell':
    key        => '34D8786F',
    key_server => 'pgp.mit.edu',
  }

  apt::source { 'dell':
    location    => 'http://linux.dell.com/repo/community/deb/latest ',
    release     => '/',
    repos       => '',
    key         => '34D8786F',
    include_src => false,
  }
}

class physical::repo::supermicro {

}
