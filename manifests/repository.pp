#  shoal repostory form where we install the shoal agent package

 class shoal::repository {
  
    package { "yum-conf-epel":
       ensure => installed,  
    }
  
   # exec { 'yum-update':
      # command => "yum update -y",
      # path => "/usr/bin",
      # before => Exec["curl-shoal-repo"],
      # require => Package["yum-conf-epel"],
      # creates => "/usr/bin/shoal-agent",
    #}
  
    exec { 'curl-shoal-repo':
       command => "curl http://shoal.heprc.uvic.ca/repo/shoal.repo -o /etc/yum.repos.d/shoal.repo",
       path => "/usr/bin",
       before => Exec["rpm-import"],
      # require => Exec["yum-update"],
       require => Package["yum-conf-epel"], 
       creates => "/etc/yum.repos.d/shoal.repo",
    }
  
    exec { 'rpm-import':
       command => "rpm --import http://hepnetcanada.ca/pubkeys/igable.asc",
       path => "/bin",
       require => Exec["curl-shoal-repo"],
       creates => "/usr/bin/shoal-agent",
       
    }
  
 }
