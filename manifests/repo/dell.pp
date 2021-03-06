# dell openmanage repo
class physical::repo::dell(
  String $mirror_url,
) {

  if defined('$::http_proxy') and str2bool($::rfc1918_gateway) {
    $key_options = "http-proxy=${::http_proxy}"
  }
  else {
    $key_options = undef
  }

  apt::key { 'dell':
    id      => '42550ABD1E80D7C1BC0BAD851285491434D8786F',
    server  => 'keyserver.ubuntu.com',
    options => $key_options
  }

  # follow the guide on https://linux.dell.com/repo/community/openmanage/
  if versioncmp($::operatingsystemrelease, '18.04') < 0 { # pre-bionic
    apt::source { 'dell':
      location => 'http://linux.dell.com/repo/community/ubuntu',
      release  => $::lsbdistcodename,
      repos    => 'openmanage',
    }
  }
  else { # bionic and later
    apt::source { 'dell':
      location => $mirror_url,
      release  => $::lsbdistcodename,
      repos    => 'main',
      require  => Apt::Key['dell'],
    }
  }

  Apt::Source <| title == 'dell' |> -> Class['apt::update'] -> Package <| tag == 'dell' |>

}
