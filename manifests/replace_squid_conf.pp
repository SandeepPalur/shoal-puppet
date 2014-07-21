class shoal::replace_squid_conf{

 file { "/var/spool/squid":
    ensure => "directory",
    mode   => 766,
 }


 file { '/etc/squid/squid.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => "puppet:///modules/shoal/squid.conf",
    #notify  => Service['frontier-squid'],
    require => File['/var/spool/squid'],
  }



 exec { 'restart frontier-squid':
      command => "service frontier-squid restart",
      require => File['/etc/squid/squid.conf'],
      path    => '/sbin'
  }
}

