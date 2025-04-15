# dell openmanage repo
class physical::repo::dell(
  String $base_mirror_url,
  String $openmanage_version,
  Optional[String] $mirror_url = undef,
  String $distro = $facts['os']['distro']['codename'],
  String $keyring_name = 'dell-nectar.gpg',
  String $keyring_source = 'http://download.rc.nectar.org.au/dell-keyring.gpg',
) {

  # mirror_url used in preference to pattern formed url
  if $mirror_url {
    $real_mirror_url = $mirror_url
  } else {
    $real_mirror_url="${base_mirror_url}${openmanage_version}/${distro}"
  }

  apt::source { 'dell':
    location => $real_mirror_url,
    release  => $distro,
    repos    => 'main',
    key      => {
      'name'   => $keyring_name,
      'source' => $keyring_source,
    },
  }

  Apt::Source <| title == 'dell' |> -> Class['apt::update'] -> Package <| tag == 'dell' |>

}
