# The shoal agent runs in the squid server and announces it to the shoal server

 class shoal::agent(
  $shoal_server_ip = undef,
 ) 
 {
 if($shoal_server_ip)
 {

   package { "shoal-agent":
      ensure => installed,
   }

  
   file_line { '/etc/shoal/shoal_agent.conf':
      path => '/etc/shoal/shoal_agent.conf',
      line => "amqp_server_url = ${shoal_server_ip}",
      match   => "amqp_server_url =.*$",
      require => Package["shoal-agent"],
      notify  => Service["shoal-agent"],
  
   } 
  
   service { 'shoal-agent':
      ensure => running,
      enable => true,
      hasstatus => false,
      #hasrestart => true,
      path => "/usr/bin",
     #require => File_line["shoal-agent"],
   }

 }
 else{
   warning('Shoal agent is NOT INSTALLED. please pass a valid ip to the parameter "shoal_server_ip" and run it again' )
   warning('eg: shoal_server_url => shoalserver.domain')
 }

}
 
