class physical::repo (
  Boolean $hwraid = true,
) {

  case $::manufacturer {
    'HP' :         { require ::physical::repo::hp }
    'Dell Inc.' :  { require ::physical::repo::dell }
  }

  if $hwraid {
    require ::physical::repo::hwraid
  }
}
