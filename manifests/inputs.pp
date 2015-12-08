# == Class: splunk::inputs 
# 
# Manage the inputs.conf file
#
# === Parameters
#
# [*path*]
#   The path to the inputs.conf
#   Default: ${::splunk::splunkhome}/etc/system/local
#
# [*host*]
#   The hostname of the sending node
#   Default: $fqdn
#
# [*source*]
#   The default source to monitor.  It is better to use the 
#   splunk::inputs::<module> types to manage the sources.
#   Default: undef
#
# [*sourcetype*]
#   The default sourcetype to monitor.  It is better to use the
#   splunk::inputs::<module> types to mange the sourcetypes.
#   Default: undef
#
# [*queue*]
#   The queuing method, parsingQueue or indexQueue.
#   Default: undef
#
# [*_tcp_routing*]
#   An array of tcpout group names.
#   Default: undef
#
# [*_syslog_routing*]
#   An array of syslog group names.
#   Default: undef
#
# [*_index_and_forward_routing*]
#   Causes all data coming from the input stanza to be labeled with
#   the value.
#   Default: undef
#
# === Examples
#
# class { 'splunk::inputs':
#   host => 'my_special_host_role',
# }
#
# splunk::inputs::monitor { '/var/log/messages':
#   index      => 'my_index_name',
#   sourcetype => 'linux_messages_syslog',
# }
#
class splunk::inputs (
  $path = "${::splunk::splunkhome}/etc/system/local",

  $host                       = $::fqdn,
  $index                      = undef,
  $source                     = undef,
  $sourcetype                 = undef,
  $queue                      = undef,
  $_tcp_routing               = undef,
  $_syslog_routing            = undef,
  $_index_and_forward_routing = undef,
  $custom_hash                = undef,
  ) {

  validate_absolute_path("${path}/inputs.conf")
  validate_string($index)

  if $source {
    validate_absolute_path($source)
  }

  validate_string($sourcetype)

  if $queue {
    validate_re($queue, '^(parsingQueue|indexQueue)')
  }

  # more validation to come soon

  concat { 'inputs.conf':
    path    => "${path}/inputs.conf",
    owner   => 'splunk',
    group   => 'splunk',
    mode    => '0644',
    warn    => true,
    require => Class['splunk::install'],
    notify  => Class['splunk::service'],
  }

  concat::fragment { "inputs.conf_header":
    target  => 'inputs.conf',
    order   => '01',
    content => template("${module_name}/inputs/01-header.erb"),
  }
}
