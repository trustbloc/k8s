#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo "Adding wget"
type wget || apk --no-cache add wget

rm -rf .build
mkdir -p .build
# TODO use orb tag url
wget https://nightly.link/trustbloc/orb/actions/artifacts/61088009.zip -O .build/orb-cli.zip
cd .build
unzip orb-cli.zip
tar -zxf orb-cli-linux-amd64.tar.gz

domain1IRI=https://orb-1.||DOMAIN||/services/orb
domain2IRI=https://orb-2.||DOMAIN||/services/orb
domain3IRI=https://orb-3.||DOMAIN||/services/orb

CA_CERT_OPT="--tls-systemcertpool=true"

if [ -f /etc/orb-add-followers/tls/ca.crt ]
then
  CA_CERT_OPT="--tls-cacerts=/etc/orb-add-followers/tls/ca.crt"
fi

# orb2 server follows orb1 server
./orb-cli-linux-amd64 follower --outbox-url=https://orb-2.||DOMAIN||/services/orb/outbox --actor=$domain2IRI --to=$domain1IRI --action=Follow $CA_CERT_OPT --auth-token=ADMIN_TOKEN

## orb1 server follows orb2 server
./orb-cli-linux-amd64 follower --outbox-url=https://orb-1.||DOMAIN||/services/orb/outbox --actor=$domain1IRI --to=$domain2IRI --action=Follow $CA_CERT_OPT --auth-token=ADMIN_TOKEN

### orb3 server follows orb2 server
./orb-cli-linux-amd64 follower --outbox-url=https://orb-3.||DOMAIN||/services/orb/outbox --actor=$domain3IRI --to=$domain2IRI --action=Follow $CA_CERT_OPT --auth-token=ADMIN_TOKEN


### orb1 invites orb2 to be a witness
./orb-cli-linux-amd64 witness --outbox-url=https://orb-1.||DOMAIN||/services/orb/outbox --actor=$domain1IRI --to=$domain2IRI --action=InviteWitness $CA_CERT_OPT --auth-token=ADMIN_TOKEN

## orb1 invites orb3 to be a witness
./orb-cli-linux-amd64 witness --outbox-url=https://orb-1.||DOMAIN||/services/orb/outbox --actor=$domain1IRI --to=$domain3IRI --action=InviteWitness $CA_CERT_OPT --auth-token=ADMIN_TOKEN

## orb2 invites orb1 to be a witness
./orb-cli-linux-amd64 witness --outbox-url=https://orb-2.||DOMAIN||/services/orb/outbox --actor=$domain2IRI --to=$domain1IRI --action=InviteWitness $CA_CERT_OPT --auth-token=ADMIN_TOKEN

## orb2 invites orb3 to be a witness
./orb-cli-linux-amd64 witness --outbox-url=https://orb-2.||DOMAIN||/services/orb/outbox --actor=$domain2IRI --to=$domain3IRI --action=InviteWitness $CA_CERT_OPT --auth-token=ADMIN_TOKEN

## orb3 invites orb1 to be a witness
./orb-cli-linux-amd64 witness --outbox-url=https://orb-3.||DOMAIN||/services/orb/outbox --actor=$domain3IRI --to=$domain1IRI --action=InviteWitness $CA_CERT_OPT --auth-token=ADMIN_TOKEN

## orb3 invites orb2 to be a witness
./orb-cli-linux-amd64 witness --outbox-url=https://orb-3.||DOMAIN||/services/orb/outbox --actor=$domain3IRI --to=$domain2IRI --action=InviteWitness $CA_CERT_OPT --auth-token=ADMIN_TOKEN
