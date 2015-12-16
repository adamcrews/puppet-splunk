class splunk::install::windows (
  $pkgname          = $::splunk::pkgname,
  $splunkhome       = $::splunk::splunkhome,
  $service_name     = $::splunk::service_name,
  $user             = $::splunk::user,
  $group            = $::splunk::group,
  $root_user        = $::splunk::root_user,
  $root_group       = $::splunk::root_group,
  ) {

  # recursively copy the contents of the auth dir
  # This is causing a restart on the second run. - TODO
  file { "${splunkhome}/etc/auth":
    owner              => $user,
    group              => $group,
    recurse            => true,
    purge              => false,
    source_permissions => ignore,
    source             => 'puppet:///modules/splunk/noarch/opt/splunk/etc/auth',
    require            => Package[$pkgname],
    before             => Service[$service_name],
  }

  acl { '${splunkhome}/etc/auth/splunkweb':
    permissions => [
      { identity => $root_user, rights => ['full'] },
      { identity => $user, rights => ['read','execute'] }
    ],
    owner => $user,
  }

  acl { '${splunkhome}/etc/auth/splunk.secret':
    permissions => [
      { identity => $root_user, rights => ['full'] },
      { identity => $user, rights => ['read','execute'] }
    ],
    owner => $user,
  }
}
