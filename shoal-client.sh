#!/bin/bash
#This script requires puppet installed.
#One needs to be root to apply this.
#This script installs shoal client

if [ "`whoami`" != "root" ]; then
  echo "This should be run by root"
  exit 1
fi

mkdir -p /etc/puppet/modules

if [ ! -f "/usr/bin/git" ]; then
  yum install git -y
fi

if [ ! -d "/etc/puppet/modules/shoal" ]; then
  git clone https://github.com/SandeepPalur/shoal-puppet.git
  mkdir -p /etc/puppet/modules/shoal && cp -r shoal-puppet/* /etc/puppet/modules/shoal

else
  cd shoal-puppet
  git pull
  cd ..
  cp -rf  shoal-puppet/* /etc/puppet/modules/shoal
fi

if [ ! -d "/etc/puppet/modules/cvmfs" ]; then
  git clone https://github.com/SandeepPalur/puppet-cvmfs.git
  mkdir -p /etc/puppet/modules/cvmfs && cp -r puppet-cvmfs/* /etc/puppet/modules/cvmfs

else
  cd puppet-cvmfs
  git pull
  cd ..
  cp -rf  puppet-cvmfs/* /etc/puppet/modules/cvmfs
fi


if [ ! -d "/etc/puppet/modules/cron" ]; then
  puppet module install torrancew/cron
fi

if [ ! -d "/etc/puppet/modules/epel" ]; then
  puppet module install stahnma/epel
fi

if [ ! -d "/etc/puppet/modules/stdlib" ]; then
  puppet module install puppetlabs/stdlib
fi

cat << EOF | puppet apply
include epel
include cvmfs::client
class {'shoal::client':
      shoal_server_url => 'http://cloudshoal.fnal.gov/nearest',
      }
Class['epel'] -> Class['cvmfs::client'] -> Class['shoal::client']
EOF

