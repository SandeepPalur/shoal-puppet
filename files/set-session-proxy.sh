proxy=`/usr/bin/shoal-client -d`
#echo $proxy
if [[ $proxy =~ 'export http_proxy=http://' ]];

then
$proxy > /usr/run-export-command.sh
chmod 755 /usr/run-export-command.sh
source /usr/run-export-command.sh
echo "Proxy set successfully!"

else
echo "Proxy not set!"
echo "No squid servers are active currently!"

fi
