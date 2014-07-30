# == Class: frontier::squid

#

# Installation and configuration of a frontier squid



#

# === Parameters

#

# [*customize_file*]

#   The customization config file to be used.

#

# [*customize_template*]

#   The customization config template to be used.

#

# [*cache_dir*]

#   The cache directory.

#

# [*install_resource*]

#   The cache directory.

#

# [*resource_path*]

#   The cache directory.

#

# === Examples

#

#  class { frontier::squid:

#    customize_file => 'puppet:///modules/mymodule/customize.sh',

#    cache_dir      => '/var/squid/cache'

#  }

#

# === Authors

#

# Alessandro De Salvo <Alessandro.DeSalvo@roma1.infn.it>

#

# === Copyright

#

# Copyright 2014 Alessandro De Salvo

#
# Added comment

class shoal::frontier (

  $customize_file = undef,

  $customize_template = undef,


  $cache_dir = $shoal::frontier_params::frontier_cache_dir,

  $install_resource = false,

  $resource_path = $shoal::frontier_params::resource_agents_path

) inherits shoal::frontier_params {

  yumrepo {'cern-frontier':

      baseurl => 'http://frontier.cern.ch/dist/rpms/',

      enabled => 1,

      gpgcheck => 1,

      gpgkey   => 'http://frontier.cern.ch/dist/rpms/cernFrontierGpgPublicKey'

  }



  package {$shoal::frontier_params::frontier_packages:

      ensure  => latest,

      require => Yumrepo['cern-frontier'],

      notify  => Service[$shoal::frontier_params::frontier_service]

  }



  if ($cache_dir) {

      file { $cache_dir:

          ensure  => directory,

          owner   => squid,

          group   => squid,

          mode    => 0755,

          require => Package[$shoal::frontier_params::frontier_packages],

          notify  => Service[$shoal::frontier_params::frontier_service]

      }

  }



  if ($customize_file) {

      file {$shoal::frontier_params::frontier_customize:

          ensure  => file,

          owner   => squid,

          group   => squid,

          mode    => 0555,

          source  => $customize_file,

          require => Package[$shoal::frontier_params::frontier_packages],

          notify  => Service[$shoal::frontier_params::frontier_service]

      }

  }




  if ($customize_template) {

      file {$shoal::frontier_params::frontier_customize:

          ensure  => file,

          owner   => squid,

          group   => squid,

          mode    => 0755,

          content => template($customize_template),

          require => Package[$shoal::frontier_params::frontier_packages],

          notify  => Service[$shoal::frontier_params::frontier_service]

      }

  }



  if ($install_resource) {

      file { $resource_path:

          ensure  => directory,

          owner   => "root",

          group   => "root",

          mode    => 0755,

      }



      file { "${resource_path}/FrontierSquid":

          ensure  => file,

          owner   => "root",

          group   => "root",

          mode    => 0755,

          source  => "puppet:///modules/frontier/FrontierSquid",

          require => File[$resource_path]

      }

  }



  service {$shoal::frontier_params::frontier_service:

      ensure     => running,

      enable     => true,

      hasrestart => true,

      require    => Package[$shoal::frontier_params::frontier_packages]

  }



file { "/var/spool/squid":

    ensure => "directory",

   #owner  => "root",


   #group  => "wheel",

    mode   => 766,

}



file { 'Replacing default squid config with new config content':

  ensure  => present,

  owner   => 'root',

  group   => 'root',

  mode    => '0755',

  path    => '/etc/squid/squid.conf',

  content  => inline_template("acl NET_LOCAL src 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16

acl all src all

acl manager proto cache_object

acl localhost src 127.0.0.1/32

acl to_localhost dst 127.0.0.0/8 0.0.0.0/32

acl localnet src 10.0.0.0/8     # RFC1918 possible internal network

acl localnet src 172.16.0.0/12  # RFC1918 possible internal network

acl localnet src 192.168.0.0/16 # RFC1918 possible internal network

acl SSL_ports port 443

acl Safe_ports port 80          # http

acl Safe_ports port 21          # ftp

acl Safe_ports port 443         # https

acl Safe_ports port 70          # gopher

acl Safe_ports port 210         # wais

acl Safe_ports port 1025-65535  # unregistered ports

acl Safe_ports port 280         # http-mgmt

acl Safe_ports port 488         # gss-http

acl Safe_ports port 591         # filemaker

acl Safe_ports port 777         # multiling http

acl CONNECT method CONNECT

http_access allow manager localhost

http_access deny manager

http_access deny !Safe_ports

http_access deny CONNECT !SSL_ports

http_access allow NET_LOCAL

acl awscloud src 172.31.0.0/16 127.0.0.1

http_access allow awscloud

http_access allow localhost

http_access deny all

acl PURGE method PURGE

http_access allow PURGE localhost

http_access deny PURGE

reply_body_max_size 10000000000 allow all

icp_access allow localnet

icp_access deny all

http_port 3128

hierarchy_stoplist cgi-bin

cache_mem 1024 MB

maximum_object_size_in_memory 256 KB

cache_dir ufs /var/spool/squid 290000 16 256

maximum_object_size 10 GB

logformat awstats %>a %ui %un [%{%d/%b/%Y:%H:%M:%S +0000}tl] \"%rm %ru HTTP/%rv\" %Hs %<st %Ss:%Sh %tr \"%{X-Frontier-Id}>h\" \"%{Referer}>h\" \"%{User-Agent}>h\"

access_log /var/log/squid/access.log awstats

logfile_daemon /usr/libexec/squid/logfile-daemon

cache_log /var/log/squid/cache.log

cache_store_log none

mime_table /etc/squid/mime.conf

pid_filename /var/run/squid/squid.pid

strip_query_terms off

unlinkd_program /usr/libexec/squid/unlinkd

refresh_pattern ^ftp:           1440    20%     10080

refresh_pattern ^gopher:        1440    0%      1440

refresh_pattern -i /cgi-bin/    0       0%      0

refresh_pattern \\.crl$          60      25%     1440

refresh_pattern \\.der$          60      25%     1440

refresh_pattern \\.pem$          60      25%     1440

refresh_pattern \\.r0$           60      25%     1440

refresh_pattern \\.pacman$       60      10%     1440

refresh_pattern .               60      20%     4320

negative_ttl 1 minute

acl shoutcast rep_header X-HTTP09-First-Line ^ICY.[0-9]

upgrade_http0.9 deny shoutcast

acl apache rep_header Server ^Apache

broken_vary_encoding allow apache

collapsed_forwarding on

connect_timeout 30 seconds

read_timeout 1 minute


request_timeout 1 minute

client_lifetime 1 hour

cache_mgr fermigrid-help@fnal.gov

cache_effective_user squid

cache_effective_group squid

umask 022

snmp_access deny all

icp_port 0

icon_directory /usr/share/squid/icons

error_directory /usr/share/squid/errors/English

ignore_ims_on_miss on

coredump_dir /var/spool/squid

 "),

notify  => Service[$shoal::frontier_params::frontier_service],

}



}

