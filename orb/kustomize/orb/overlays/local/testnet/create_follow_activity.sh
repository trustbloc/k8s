#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo "Adding curl"
apk --no-cache add curl

domain1IRI=https://orb-1.||DOMAIN||/services/orb
domain2IRI=https://orb-2.||DOMAIN||/services/orb
domain3IRI=https://orb-3.||DOMAIN||/services/orb

# orb2 server follows orb1 server
followActivityORB2ToORB1=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":"https://www.w3.org/ns/activitystreams","id":"'$domain2IRI'/activities/'$(( ( RANDOM % 10 )  + 1 ))'","type":"Follow","actor":"'$domain2IRI'","to":"'$domain1IRI'","object":"'$domain1IRI'"}' \
   --insecure https://orb-2.||DOMAIN||/services/orb/outbox)

# orb1 server follows orb2 server
followActivityORB1ToORB2=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":"https://www.w3.org/ns/activitystreams","id":"'$domain1IRI'/activities/'$(( ( RANDOM % 10 )  + 1 ))'","type":"Follow","actor":"'$domain1IRI'","to":"'$domain2IRI'","object":"'$domain2IRI'"}' \
   --insecure https://orb-1.||DOMAIN||/services/orb/outbox)


## orb3 server follows orb2 server
followActivityORB3ToORB2=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":"https://www.w3.org/ns/activitystreams","id":"'$domain3IRI'/activities/'$(( ( RANDOM % 10 )  + 1 ))'","type":"Follow","actor":"'$domain3IRI'","to":"'$domain2IRI'","object":"'$domain2IRI'"}' \
   --insecure https://orb-3.||DOMAIN||/services/orb/outbox)


## orb1 invites orb2 to be a witness
inviteWitnessORB1ToORB2=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":["https://www.w3.org/ns/activitystreams","https://trustbloc.github.io/did-method-orb/contexts/anchor/v1"],"id":"'$domain1IRI'/activities/'$(( ( RANDOM % 10 )  + 1 ))'","type":"InviteWitness","actor":"'$domain1IRI'","to":"'$domain2IRI'","object":"'$domain2IRI'"}' \
   --insecure https://orb-1.||DOMAIN||/services/orb/outbox)

# orb1 invites orb3 to be a witness
inviteWitnessORB1ToORB3=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":["https://www.w3.org/ns/activitystreams","https://trustbloc.github.io/did-method-orb/contexts/anchor/v1"],"id":"'$domain1IRI'/activities/'$(( ( RANDOM % 10 )  + 1 ))'","type":"InviteWitness","actor":"'$domain1IRI'","to":"'$domain3IRI'","object":"'$domain3IRI'"}' \
   --insecure https://orb-1.||DOMAIN||/services/orb/outbox)

# orb2 invites orb1 to be a witness
inviteWitnessORB2ToORB1=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":["https://www.w3.org/ns/activitystreams","https://trustbloc.github.io/did-method-orb/contexts/anchor/v1"],"id":"'$domain2IRI'/activities/'$(( ( RANDOM % 10 )  + 1 ))'","type":"InviteWitness","actor":"'$domain2IRI'","to":"'$domain1IRI'","object":"'$domain1IRI'"}' \
   --insecure https://orb-2.||DOMAIN||/services/orb/outbox)

# orb2 invites orb3 to be a witness
inviteWitnessORB2ToORB3=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":["https://www.w3.org/ns/activitystreams","https://trustbloc.github.io/did-method-orb/contexts/anchor/v1"],"id":"'$domain2IRI'/activities/'$(( ( RANDOM % 10 )  + 1 ))'","type":"InviteWitness","actor":"'$domain2IRI'","to":"'$domain3IRI'","object":"'$domain3IRI'"}' \
   --insecure https://orb-2.||DOMAIN||/services/orb/outbox)

# orb3 invites orb1 to be a witness
inviteWitnessORB3ToORB1=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":["https://www.w3.org/ns/activitystreams","https://trustbloc.github.io/did-method-orb/contexts/anchor/v1"],"id":"'$domain3IRI'/activities/'$(( ( RANDOM % 10 )  + 1 ))'","type":"InviteWitness","actor":"'$domain3IRI'","to":"'$domain1IRI'","object":"'$domain1IRI'"}' \
   --insecure https://orb-3.||DOMAIN||/services/orb/outbox)

# orb3 invites orb2 to be a witness
inviteWitnessORB3ToORB2=$(curl -o /dev/null -s -w "%{http_code}" --header "Content-Type: application/json" \
   --request POST \
   --data '{"@context":["https://www.w3.org/ns/activitystreams","https://trustbloc.github.io/did-method-orb/contexts/anchor/v1"],"id":"'$domain3IRI'/activities/'$(( ( RANDOM % 10 )  + 1 ))'","type":"InviteWitness","actor":"'$domain3IRI'","to":"'$domain2IRI'","object":"'$domain2IRI'"}' \
   --insecure https://orb-3.||DOMAIN||/services/orb/outbox)


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

checkIsCreated $followActivityORB2ToORB1 follow-activity-orb2-to-orb1
checkIsCreated $followActivityORB1ToORB2 follow-activity-orb1-to-orb2
checkIsCreated $followActivityORB3ToORB2 follow-activity-orb3-to-orb2
checkIsCreated $inviteWitnessORB1ToORB2 invite-witnessy-orb1-to-orb2
checkIsCreated $inviteWitnessORB1ToORB3 invite-witnessy-orb1-to-orb3
checkIsCreated $inviteWitnessORB2ToORB1 invite-witnessy-orb2-to-orb1
checkIsCreated $inviteWitnessORB2ToORB3 invite-witnessy-orb2-to-orb3
checkIsCreated $inviteWitnessORB3ToORB1 invite-witnessy-orb3-to-orb1
checkIsCreated $inviteWitnessORB3ToORB2 invite-witnessy-orb3-to-orb2
