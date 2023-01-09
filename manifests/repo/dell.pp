# dell openmanage repo
class physical::repo::dell(
  String $base_mirror_url,
  String $openmanage_version,
  String $mirror_url = undef,
  String $distro = $facts['os']['distro']['codename'],
) {

  # mirror_url used in preference to pattern formed url
  if $mirror_url {
    $real_mirror_url = $mirror_url
  } else {
    $real_mirror_url="${base_mirror_url}${openmanage_version}/${distro}"
  }

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
      release  => $distro,
      repos    => 'openmanage',
    }
  }
  else { # bionic and later
    apt::source { 'dell':
      location => $real_mirror_url,
      release  => $distro,
      repos    => 'main',
      require  => Apt::Key['dell'],
    }
  }

  Apt::Source <| title == 'dell' |> -> Class['apt::update'] -> Package <| tag == 'dell' |>

}
