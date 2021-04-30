#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo "Adding curl"
apk --no-cache add curl

domain1IRI=https://orb-1.||DOMAIN||/services/orb
domain2IRI=https://orb-2.||DOMAIN||/services/orb
orb1FollowID=1
orb2FollowID=2
orb1InviteWitnessID=3
orb2InviteWitnessID=4

# orb2 server follows orb1 server
followActivityORB2=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":"https://www.w3.org/ns/activitystreams","id":"'$domain2IRI'/activities/'$orb2FollowID'","type":"Follow","actor":"'$domain2IRI'","to":"'$domain1IRI'","object":"'$domain1IRI'"}' \
   --insecure https://orb-1.||DOMAIN||/services/orb/inbox)

# orb1 server follows orb2 server
followActivityORB1=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":"https://www.w3.org/ns/activitystreams","id":"'$domain1IRI'/activities/'$orb1FollowID'","type":"Follow","actor":"'$domain1IRI'","to":"'$domain2IRI'","object":"'$domain2IRI'"}' \
   --insecure https://orb-2.||DOMAIN||/services/orb/inbox)

# orb1 invites orb2 to be a witness
inviteWitnessORB1=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":["https://www.w3.org/ns/activitystreams","https://trustbloc.github.io/did-method-orb/contexts/anchor/v1"],"id":"'$domain1IRI'/activities/'$orb1InviteWitnessID'","type":"InviteWitness","actor":"'$domain1IRI'","to":"'$domain2IRI'","object":"'$domain2IRI'"}' \
   --insecure https://orb-2.||DOMAIN||/services/orb/inbox)

# orb2 invites orb1 to be a witness
inviteWitnessORB2=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":["https://www.w3.org/ns/activitystreams","https://trustbloc.github.io/did-method-orb/contexts/anchor/v1"],"id":"'$domain2IRI'/activities/'$orb2InviteWitnessID'","type":"InviteWitness","actor":"'$domain2IRI'","to":"'$domain1IRI'","object":"'$domain1IRI'"}' \
   --insecure https://orb-1.||DOMAIN||/services/orb/inbox)


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

checkIsCreated $followActivityORB2 follow-activity-orb2
checkIsCreated $followActivityORB1 follow-activity-orb1
checkIsCreated $inviteWitnessORB1 invite-witnessy-orb1
checkIsCreated $inviteWitnessORB2 invite-witnessy-orb2
