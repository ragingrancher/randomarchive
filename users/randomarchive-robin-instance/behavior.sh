#!/bin/sh
sudo apt-get install -y jq
while true
do        
        RANDOMARCHIVELB_IP=$(gcloud compute forwarding-rules list --filter="NAME ~ randomarchive" --format=json | jq -r '.[] | .IPAddress')
        #echo "Current randomarchive loadbalancer ip is: $RANDOMARCHIVELB_IP"
        gcloud sql instances list --filter="NAME ~ randomarchive">privateip.txt
        RANDOMARCHIVESQL_IP=$(awk 'NR == 2 {print $6}' privateip.txt)
        #echo "Current randomarchive sql private ip is: $RANDOMARCHIVESQL_IP"
        ISBREAKAGEZERO=$(echo "SELECT is_active FROM breakage_scenario WHERE scenario=3;" | mysql -N --database=randomarchive --host="$RANDOMARCHIVESQL_IP" --user=root --password=CorrectHorseBatteryStaple)
        #echo "Is breakage scenario 3 running?: $ISBREAKAGEZERO"
        if [ $ISBREAKAGEZERO -eq 1 ] 
        then
                for i in $(seq 1 12)
                do
                        curl -X POST http://"$RANDOMARCHIVELB_IP"/register -d @newuser.json -H 'Content-Type: application/json'
                        sleep 15
                done
        else
                for i in $(seq 1 12)
                do
                        curl -I http://"$RANDOMARCHIVELB_IP"/
                        sleep 5
                done
        fi
done
