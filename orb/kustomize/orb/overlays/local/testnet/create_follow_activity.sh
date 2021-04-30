#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo "Adding curl"
apk --no-cache add curl

domain1IRI=https://orb-1.||DOMAIN||/services/orb
domain2IRI=https://orb-2.||DOMAIN||/services/orb
followID=1
inviteWitnessID=2

followActivity=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":"https://www.w3.org/ns/activitystreams","id":"'$domain2IRI'/activities/'$followID'","type":"Follow","actor":"'$domain2IRI'","to":"'$domain1IRI'","object":"'$domain1IRI'"}' \
   --insecure https://orb-1.||DOMAIN||/services/orb/inbox)


inviteWitness=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":["https://www.w3.org/ns/activitystreams","https://trustbloc.github.io/did-method-orb/contexts/anchor/v1"],"id":"'$domain1IRI'/activities/'$inviteWitnessID'","type":"InviteWitness","actor":"'$domain1IRI'","to":"'$domain2IRI'","object":"'$domain2IRI'"}' \
   --insecure https://orb-2.||DOMAIN||/services/orb/inbox)



checkIsCreated()
{
   if [ "$1" == "200" ]
   then
     echo "$2 is created"
   else
     echo "failed create $2 response code $1"
     exit 1
   fi
}

checkIsCreated $followActivity follow-activity
checkIsCreated $inviteWitness invite-witnessy
