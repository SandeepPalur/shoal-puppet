# Installs shoal server dependancy packages 
class shoal::server_dependancies{
  Package { ensure => "installed" }

  package { "wget": } 
  package { "gcc": }
  package { "make":   }
  package { "ncurses":}
  package { "ncurses-devel":}
  package { "openssl-devel":}
  package { "libxslt":}
  package { "zip":}
  package { "unzip":}
  package { "nc":}
  package { "git":}

 }
