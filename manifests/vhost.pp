define apache::vhost($ensure=running, $source=false, $content=false, $replace=false) {
  include apache

  $apache_sites_available = $apache::apache_sites_available
  $apache_sites_enabled = $apache::apache_sites_enabled
  $apache_listen_address = $apache::apache_listen_address
  $apache_listen_port = $apache::apache_listen_port
  

  if $ensure in [ present, running, absent, purged ] {
    $ensure_real = $ensure
  } else {
    fail('Valid values for ensure: present, running, absent, purged, or stopped')
  }

  if $source and $content {
    fail('You can only specify one of "source" or "content"')
  }

  $source_real = $source ? {
    false   => undef,
    default => $source
  }

  $content_real = $content ? {
    false   => template("apache/site.erb"),
    default => $content
  }

  $files_ensure = $ensure_real ? {
    /(absent|purged)/ => absent,
    default           => file
  }
  
  file {
    "${apache_sites_available}/${name}":
      ensure  => $files_ensure,
      source  => $source_real,
      content => $content_real,
      replace => $replace;
    "${apache_sites_enabled}/${name}":
      ensure => link,
      target => "${apache_sites_available}/${name}",
      notify => Service['apache'];
    "/var/www/${name}":
      path => "/var/www/${name}",
      ensure => directory,
      group => 'www-data',
      owner => 'www-data';
  }
}
