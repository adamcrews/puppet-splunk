class splunk::install (
  $license          = $::splunk::license,
  $pkgname          = $::splunk::pkgname,
  $splunkadmin      = $::splunk::splunkadmin,
  $localusers       = $::splunk::localusers,
  $splunkhome       = $::splunk::splunkhome,
  $type             = $::splunk::type,
  $version          = $::splunk::version,
  $package_source   = $::splunk::package_source,
  $package_provider = $::splunk::package_provider,
  $replace_passwd   = $::splunk::replace_passwd,
  $service_name     = $::splunk::service_name,
  $user             = $::splunk::user,
  $group            = $::splunk::group,
  $root_user        = $::splunk::root_user,
  $root_group       = $::splunk::root_group,
  ) {

  $splunk_perms = $::osfamily ? {
    'windows' => undef,
    default   => '0644',
  }

  $root_perms = $::osfamily ? {
    'windows' => undef,
    default   => '0600',
  }

  package { $pkgname:
    ensure   => $version,
    provider => $package_provider,
    source   => $package_source,
  }

  if $::osfamily != 'windows' {
    file { "/etc/init.d/${service_name}":
      ensure  => file,
      mode    => '0544',
      owner   => 'root',
      group   => 'root',
      source  => "puppet:///modules/splunk/${::osfamily}/etc/init.d/${service_name}",
      require => Package[$pkgname],
      notify  => Service[$service_name],
    }
  }

  # inifile
  ini_setting { 'Server Name':
    ensure  => present,
    path    => "${splunkhome}/etc/system/local/server.conf",
    section => 'general',
    setting => 'serverName',
    value   => $::fqdn,
    require => Package[$pkgname],
  }

  ini_setting { 'SSL v3 only':
    ensure  => present,
    path    => "${splunkhome}/etc/system/local/server.conf",
    section => 'sslConfig',
    setting => 'supportSSLV3Only',
    value   => 'True',
    require => Package[$pkgname],
  }

  file { "${splunkhome}/etc/splunk.license":
    ensure  => present,
    mode    => $splunk_perms,
    owner   => $user,
    group   => $group,
    backup  => true,
    source  => $license,
    require => Package[$pkgname],
    notify  => Service[$service_name],
  }

  file { "${splunkhome}/etc/passwd":
    ensure  => present,
    replace => $replace_passwd,
    mode    => $root_perms,
    owner   => $root_user,
    group   => $root_group,
    backup  => true,
    content => template('splunk/opt/splunk/etc/passwd.erb'),
    require => Package[$pkgname],
  }

  # recursively copy the contents of the auth dir
  # This is causing a restart on the second run. - TODO
  file { "${splunkhome}/etc/auth":
      mode               => $root_perms,
      owner              => $user,
      group              => $group,
      recurse            => true,
      purge              => false,
      source_permissions => ignore,
      source             => 'puppet:///modules/splunk/noarch/opt/splunk/etc/auth',
      require            => Package[$pkgname],
      before             => Service[$service_name],
  }
}
