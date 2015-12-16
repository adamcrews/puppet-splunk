class splunk::install::linux (
  $user         = $::splunk::user,
  $group        = $::splunk::group,
  $splunkhome   = $::splunk::splunkhome,
  $pkgname      = $::splunk::pkgname,
  $service_name = $::splunk::service_name,
) {

  file { "/etc/init.d/${service_name}":
    ensure  => file,
    mode    => '0544',
    owner   => 'root',
    group   => 'root',
    source  => "puppet:///modules/splunk/${::osfamily}/etc/init.d/${service_name}",
    require => Package[$pkgname],
    notify  => Service[$service_name],
  }

  # recursively copy the contents of the auth dir
  # This is causing a restart on the second run. - TODO
  file { "${splunkhome}/etc/auth":
    mode    => '0644',
    owner   => $user,
    group   => $group,
    recurse => true,
    purge   => false,
    source  => 'puppet:///modules/splunk/noarch/opt/splunk/etc/auth',
    require => Package[$pkgname],
    before  => Service[$service_name],
  }
}
