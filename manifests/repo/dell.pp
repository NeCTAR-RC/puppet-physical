# dell openmanage repo
class physical::repo::dell(
  String $base_mirror_url,
  String $openmanage_version,
  Optional[String] $mirror_url = undef,
  String $distro = $facts['os']['distro']['codename'],
) {

  # mirror_url used in preference to pattern formed url
  if $mirror_url {
    $real_mirror_url = $mirror_url
  } else {
    $real_mirror_url="${base_mirror_url}${openmanage_version}/${distro}"
  }

  apt::key { 'dell':
    id      => '42550ABD1E80D7C1BC0BAD851285491434D8786F',
    server  => 'keyserver.ubuntu.com',
  }

  # follow the guide on https://linux.dell.com/repo/community/openmanage/
  if versioncmp($facts['os']['release']['full'], '18.04') < 0 { # pre-bionic
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
