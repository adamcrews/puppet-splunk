class splunk::service {
  service {
    $::splunk::service_name:
      ensure     => $::splunk::service_ensure,
      enable     => $::splunk::service_enable,
      hasrestart => true,
  }
}
