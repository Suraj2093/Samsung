#!/bin/sh

adddate() {
    while IFS= read -r line; do
        printf '%s %s\n' "$(date "+%Y-%m-%d %H:%M:%S")" "$line";
    done
}

ip=$(curl ifconfig.me)
url="https://$ip/api/serverInfo"

echo "Cluster IP: $ip" | adddate >> samsung.log
echo "Cluster URL: $url" | adddate >> samsung.log

sleep 300

N=0
echo "Fetching details from api server" | adddate >> samsung.log
while [ $N -lt 2 ]
do
   echo "curl -X GET --header 'Accept: application/json' -k $url" | adddate >> samsung.log
   curl -X GET --header 'Accept: application/json' -k $url >> samsung.json 2>&1
   flag=$?; if [ $flag != 0 ] ; then echo "ERROR ! Cluster Deployment Failed " | adddate >> samsung.log; rm samsung.json; exit $flag; fi
   grep clusterState samsung.json | adddate >> samsung.log
   if grep -o ACTIVE samsung.json
   then
   echo "Cluster state is ACTIVE !!" | adddate >> samsung.log
   N=2
   rm samsung.json
   else
   echo "Cluster state is pending ..." | adddate >> samsung.log
   sleep 10
   rm samsung.json
   fi
done

if [ $N -eq 2 ]
then
    echo "Cluster is deployed successfully!" | adddate >> samsung.log
else
    echo "Deployment is taking too long..." | adddate >> samsung.log
    echo "Cluster deployment failed!" | adddate >> samsung.log
fi

echo "Done" | adddate >> samsung.log
