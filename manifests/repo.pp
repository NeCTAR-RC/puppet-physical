class physical::repo (
  Boolean $hwraid = true,
) {

  case $facts['dmi']['manufacturer'] {
    'HP':         { require physical::repo::hp }
    'Dell Inc.':  { require physical::repo::dell }
    default:      {}
  }

  if $hwraid {
    require physical::repo::hwraid
  }
}
