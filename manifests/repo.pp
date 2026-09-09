class physical::repo (
  Boolean $hwraid = true,
  Boolean $openmanage = true,
) {

  case $facts['dmi']['manufacturer'] {
    'HP':         { require physical::repo::hp }
    'Dell Inc.':  {
      if $openmanage {
        require physical::repo::dell
      }
    }
    default:      {}
  }

  if $hwraid {
    require physical::repo::hwraid
  }
}
