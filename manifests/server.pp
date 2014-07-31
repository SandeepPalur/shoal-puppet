 class shoal::server{

  exec { 'git-shoal-server':
    command => "git clone https://github.com/SandeepPalur/shoal.git",
    cwd => "/usr",
    path => "/usr/bin",
    before => Exec["install-shoal-server"],
    creates => "/usr/shoal",
  }

  exec { 'install-shoal-server':
    command => "python setup.py install",
    cwd => "/usr/shoal/shoal-server",
    path => "/usr/bin",
    require => Exec["git-shoal-server"],
    creates => "/etc/shoal/shoal_server.conf",
  }

  exec { "wget-pip":
    command => "wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate",
    before => Exec["install-pip"],
    require => Exec["install-shoal-server"],
    path => "/usr/bin",
    cwd => "/usr",
    creates => "/usr/bin/pip",
  }


  exec { "install-pip":
    path => "/usr/bin",
    cwd => "/usr",
    command => "python get-pip.py",
    require => Exec["wget-pip"],
    before => Exec["install-webpy"],
    creates => "/usr/bin/pip",
  }

  exec { "install-webpy":
    path => "/usr/bin",
    command => "pip install web.py",
    require => Exec["install-pip"],
    before  => Exec["install-pygeoip"],
    creates => "/usr/lib/python2.6/site-packages/web.py-0.37-py2.6.egg-info",
  }

  exec { "install-pygeoip":
    path => "/usr/bin",
    command => "pip install pygeoip",
    require => Exec["install-webpy"],
    before  => Exec["install-pika"],
    creates => "/usr/lib/python2.6/site-packages/pygeoip",
  }

  exec { "install-pika":
    path => "/usr/bin",
    command => "pip install pika",
    creates => "/usr/lib/python2.6/site-packages/pika",
  }

  file { '/usr/bin/shoal-server.py':
    require => Exec["install-pika"],
    ensure  => present,
    owner   => 'root',
    source  => "puppet:///modules/shoal/shoal-server.py",
  }

  exec { "Run shoal server script":
    path => "/usr/bin",
    command => "python /usr/bin/shoal-server.py",
    require => File['/usr/bin/shoal-server.py'],
    refreshonly => true,
    subscribe   => File["/usr/bin/shoal-server.py"],
  }

 }


