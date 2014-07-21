# The shoal client runs in the WorkeNodes and sets up the squid proxy according to what the server tells

 class shoal::client(

  $shoal_server_url = undef,
 )
 {
 if($shoal_server_url)
 {
    package { 'git':
      ensure => installed,
      before => Exec['git-shoal-client'],
    }

    exec { 'git-shoal-client':
      command => "git clone git://github.com/hep-gc/shoal.git",
      path => "/usr/bin",
      cwd => "/usr",
      require => Package['git'],
      before => Exec['install-shoal-client'],
      creates => "/usr/shoal"
    }

    exec { 'install-shoal-client':
      command => "python setup.py install",
      cwd => "/usr/shoal/shoal-client/",
      path => "/usr/bin",
      require => Exec['git-shoal-client'],
      creates => "/etc/shoal/shoal_client.conf",
    }


    file_line { '/etc/shoal/shoal_client.conf':
      path => '/etc/shoal/shoal_client.conf',
      line => "shoal_server_url = ${shoal_server_url}",
      require => Exec['install-shoal-client'],
      match   => "shoal_server_url =.*$",
    }

    file { '/usr/bin/shoal-client':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      source  => "puppet:///modules/shoal/shoal-client",
      require => Exec['install-shoal-client'],
    } 

    exec { 'run-shoal-client':
      command => "shoal-client",
      path => "/usr/bin",
      require => File['/usr/bin/shoal-client'],
      refreshonly => true,
      subscribe   => File["/usr/bin/shoal-client"],
    }


    cron::job{'shoal-client':
      minute      => '0,30',
      hour        => '*',
      date        => '*',
      month       => '*',
      weekday     => '*',
      user        => 'root',
      command     => '/usr/bin/shoal-client >> /var/log/cron_shoal_client.log',
      environment => [ 'MAILTO=psandeep@hawk.iit.edu' ];
    }

    file { '/usr/bin/set-session-proxy.sh':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      source  => "puppet:///modules/shoal/set-session-proxy.sh",
    }

  }


 else {
    warning('Shoal client is NOT INSTALLED. please pass a valid address to the parameter "shoal_server_url" and run it again' )
    warning('eg: shoal_server_url => \'http://shoalserver.domain/nearest\' ')

 }

}
#exec { 'run-set-session-proxy-script':
 # command => "source set-session-proxy.sh",
 # path => "/usr/bin",
 # require => File['Add script to set session proxy'],
#}
 

