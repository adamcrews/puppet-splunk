# == Defined Type: splunk::ta::files
# splunk::ta::files will install a TA from the file bucket from the
# Splunk Module, or more correctly from the site/ Splunk Module
#
# === Parameters
#
# Document parameters here.
#
# [configfile]
#   Path to extracted Splunk TA on the Puppet Master.
#
# [status]
#   App Status. Defaults to enabled
#
# [inputfile]
#   Location of the inputfile template to use for the install TA/APP
#   the format of the input should be <modulename>/<path/to/template.erb
#
# === Examples
#
# splunk::ta::files { 'Splunk_TA_nix': }
define splunk::ta::files (
  $configfile = "puppet:///modules/splunk/ta/${title}",
  $index      = $::splunk::index,
  $inputfile  = "splunk/${title}/inputs.conf.erb",
  $status     = 'enabled',
  $splunkhome = $::splunk::splunkhome,
  $user       = $::splunk::user,
  $group      = $::splunk::group,
  $root_user  = $::splunk::root_user,
  $root_group = $::splunk::root_group,
) {

  File { 
    owner   => $user,
    group   => $group,
    mode    => '0644',
    ignore  => '*.py[oc]',
    require => Class['splunk::install'],
    notify  => Class['splunk::service'],
    before  => Ini_setting["Enable Splunk ${title} TA"],
  }

  file { "${splunkhome}/etc/apps/${title}":
    ensure             => present,
    recurse            => true,
    purge              => false,
    source             => $configfile,
    source_permissions => ignore,
  } 

  if $::osfamily == 'windows' {
    acl { "${splunkhome}/etc/apps/${title}":
      permissions => [
        { identity => $root_user, rights => ['full'] },
        { identity => $user, rights => ['read','execute'] }
      ],
      owner       => $user,
      require     => Class['splunk::install'],
      before      => Class['splunk::service'],
    }
  }

  file { "${splunkhome}/etc/apps/${title}/local/inputs.conf":
    ensure  => file,
    content => template($inputfile),
  }

  ini_setting { "Enable Splunk ${title} TA":
    ensure  => present,
    path    => "${splunkhome}/etc/apps/${title}/local/app.conf",
    section => 'install',
    setting => 'state',
    value   => $status,
    require => Class['splunk::install'],
    notify  => Class['splunk::service'],
  }
}
