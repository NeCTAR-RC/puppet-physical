class physical::repo::hp {

  apt::key { 'hp':
    id     => '882F7199B20F94BD7E3E690EFADD8D64B1275EA3',
    source => 'https://downloads.linux.hpe.com/SDR/repo/mcp/GPG-KEY-mcp',
  }

  apt::source { 'hp':
    location => 'http://downloads.linux.hpe.com/SDR/downloads/MCP/ubuntu',
    release  => "${facts['os']['distro']['codename']}/current",
    repos    => 'non-free',
    require  => Apt::Key['hp'],
  }
}
