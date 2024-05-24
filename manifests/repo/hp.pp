class physical::repo::hp {

  if defined('$::http_proxy') and str2bool($facts['rfc1918_gateway']) {
    $key_options = "http-proxy=${facts['http_proxy']}"
  }
  else {
    $key_options = undef
  }

  apt::key { 'hp':
    id      => '882F7199B20F94BD7E3E690EFADD8D64B1275EA3',
    server  => 'pool.sks-keyservers.net',
    options => $key_options
  }

  apt::source { 'hp':
    location => 'http://downloads.linux.hpe.com/SDR/downloads/MCP/ubuntu',
    release  => "${facts['os']['distro']['codename']}/current",
    repos    => 'non-free',
    require  => Apt::Key['hp'],
  }
}
