class physical::repo {

  case $::manufacturer {
    'HP' :         { require ::physical::repo::hp }
    'Dell Inc.' :  { require ::physical::repo::dell }
  }
  require ::physical::repo::hwraid
}

class physical::repo::hwraid {

  if defined('$::http_proxy') and str2bool($::rfc1918_gateway) {
    $key_options = "http-proxy=${::http_proxy}"
  }
  else {
    $key_options = undef
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

  if defined('$::http_proxy') and str2bool($::rfc1918_gateway) {
    $key_options = "http-proxy=${::http_proxy}"
  }
  else {
    $key_options = undef
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

  if defined('$::http_proxy') and str2bool($::rfc1918_gateway) {
    $key_options = "http-proxy=${::http_proxy}"
  }
  else {
    $key_options = undef
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
