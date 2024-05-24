class physical::repo::hwraid($release=$facts['os']['distro']['codename']) {

  apt::key { 'hwraid':
    id      => '0073C11919A641464163F7116005210E23B3D3B4',
    server  => 'keyserver.ubuntu.com',
  }

  apt::source { 'hwraid':
    location => 'http://hwraid.le-vert.net/ubuntu',
    release  => $release,
    repos    => 'main',
    require  => Apt::Key['hwraid'],
  }
}

