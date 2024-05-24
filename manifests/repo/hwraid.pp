class physical::repo::hwraid($release=$facts['os']['distro']['codename']) {

  if defined('$::http_proxy') and str2bool($facts['rfc1918_gateway']) {
    $key_options = "http-proxy=${facts['http_proxy']}"
  }
  else {
    $key_options = undef
  }

  apt::key { 'hwraid':
    id      => '0073C11919A641464163F7116005210E23B3D3B4',
    server  => 'keyserver.ubuntu.com',
    options => $key_options
  }

  apt::source { 'hwraid':
    location => 'http://hwraid.le-vert.net/ubuntu',
    release  => $release,
    repos    => 'main',
    require  => Apt::Key['hwraid'],
  }
}

