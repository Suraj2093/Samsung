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

sleep 60

N=0
echo "Fetching details from api server" | adddate >> samsung.log
while [ $N -lt 2 ]
do
   echo "curl -X GET --header 'Accept: application/json' -k $url" | adddate >> samsung.log
   curl -X GET --header 'Accept: application/json' -k $url >> samsung.json 2>&1
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

echo "Done" | adddate >> samsung.log
