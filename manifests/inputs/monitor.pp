# Specify a path to monitor
# splunk::inputs::monitor { '/path/to/log/file': 
#   
# }
# 
# generates:
#
define splunk::inputs::monitor (
  $target = 'inputs.conf',
  $order  = '50',

  $index,
  $sourcetype                     = undef,
  $source                         = undef,
  $host_regex                     = undef,
  $host_segment                   = undef,
  $whitelist                      = undef,
  $blacklist                      = undef,
  $crcsalt                        = undef,
  $initcrclength                  = undef,
  $ignoreolderthan                = undef,
  $followtail                     = undef,
  $alwaysopenfile                 = undef,
  $time_before_close              = undef,
  $multiline_event_extra_waittime = undef,
  $recursive                      = undef,
  $followsymlink                  = undef,
  $custom_hash                    = undef,
) {

  validate_absolute_path($title)
  validate_string($index)
  validate_string($sourcetype)

  if $source {
    validate_absolute_path($source)
  }

  if $host_segment {
    validate_integer($host_segment)
  }

  validate_string($crcsalt)

  if $initcrclength {
    validate_integer($initcrclength)
    if ($initcrclength < 256) or ($initcrclength > 1048576) {
      fail ('Error: inticrclength must be between 256 and 1048576')
    }
  }

  if $ignoreolderthan {
    validate_re($ignoreolderthan, '^\d+[smhd]$')
  }

  if $followtail {
    validate_re($followtail, '^[01]$')
  }

  if $alwaysopenfile {
    validate_re($alwaysopenfile, '^[01]$')
  }

  if $time_before_close {
    validate_integer($time_before_close)
  }

  if $multiline_event_extra_waittime {
    validate_bool($multiline_event_extra_waittime)
  }

  if $recursive {
    validate_bool($recursive)
  }

  if $followsymlink {
    validate_bool($followsymlink)
  }

  concat_fragment { "inputs::monitor::${title}":
    target  => $target,
    order   => $order,
    content => template("${module_name}/50-monitor.erb"),
  }
}
