# Installs wsgi module for apache and hosts shoal server
 class shoal::host_server{

 $rabbitmq_server_url = "localhost" 
  
  file { "/var/run/wsgi":
    ensure => "directory",
  }

  package { "httpd":
    ensure => installed,
  }

  exec { 'install-wsgi':
    command => "yum install mod_wsgi -y",
    path => "/usr/bin",
    creates => "/usr/lib64/httpd/modules/mod_wsgi.so",
  }

  file_line { 'Add wsgi module to /etc/httpd/conf/httpd.conf':
    path => '/etc/httpd/conf/httpd.conf', 
    line => 'LoadModule wsgi_module modules/mod_wsgi.so',
    require => Exec['install-wsgi'],
    notify  => Service["httpd"],
  }

  file_line { '/etc/httpd/conf/httpd.conf':
    path => '/etc/httpd/conf/httpd.conf',
    line => 'WSGISocketPrefix /var/run/wsgi',
    require => Exec['install-wsgi'],
    notify  => Service["httpd"],
  }

  exec { 'Host shoal on apache':
    command => "mv /var/shoal/ /var/www/",
    path => "/bin",
    creates => "/var/www/shoal",
  }

  file_line { 'changing shoal dir in /etc/shoal/shoal_server.conf':
    path => '/etc/shoal/shoal_server.conf',
    line => 'shoal_dir = /var/www/shoal/',
    require => Exec['install-wsgi'],
    match   => "shoal_dir =.*$",
  }

  file_line { 'changing amqp server url in /etc/shoal/shoal_server.conf':
    path => '/etc/shoal/shoal_server.conf',
    line => "amqp_server_url = ${rabbitmq_server_url}",
    require => Exec['install-wsgi'],
    match   => "amqp_server_url =.*$",
    notify  => Service["httpd"],
  }


  file { '/etc/httpd/conf.d/shoal.conf':
    ensure  => present,
    source  => "puppet:///modules/shoal/shoal.conf", 
  }

  file {"/var/log/shoal_server.log":
    mode => '777', 
   #recurse => true,
  }

  file {"/var/www/shoal/scripts/shoal_wsgi.py":
    mode => '755', 
   #recurse => true,
  }


  service { 'httpd':
    ensure => running,
    path => "/usr/sbin/",
    require => Exec['install-wsgi'],
  }

 }

