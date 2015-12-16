class splunk::params {
  $configure_outputs = true
  $index             = 'os'
  $index_hash        = { }
  $nagios_contacts   = undef
  $splunkadmin       = ':admin:$1$QfZoXMjP$jafmv2ASM45lllqaXHeXv/::Administrator:admin:changeme@example.com:'
  $target_group      = { example1 => 'server1.example.com',
                        example2 => 'server2.example.com' }
  $type              = 'uf'
  $localusers        = undef
  $output_hash       = { }
  $port              = '9997'
  $proxyserver       = undef
  $purge             = undef
  $version           = 'installed'
  $replace_passwd    = 'no'

  if $::mode == maintenance {
    $service_ensure = 'stopped'
    $service_enable = false
  } else {
    $service_ensure = 'running'
    $service_enable = true
  }

  case $::osfamily {
    'windows': {
      $service_name     = 'SplunkForwarder'
      $package_provider = 'chocolatey'
      $user             = 'Administrator'
      $group            = 'Administrators'
      # TODO: this should probably be set to Administrator or similar
      $root_user        = 'SYSTEM'
      $root_group       = 'Administrators'
    }

    default: {
      $service_name = 'splunk'
      $user         = 'splunk'
      $group        = 'splunk'
      $root_user    = 'root'
      $root_group   = 'root'
    }
  }
}
