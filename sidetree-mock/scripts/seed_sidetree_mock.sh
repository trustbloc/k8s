#!/bin/sh
#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

echo "Seeding Sidetree ..."

if [ "${SIDETREE_OUTPUT_DIR}x" == "x" ]; then
    echo "SIDETREE_OUTPUT_DIR env not set"
    exit 1
fi

mkdir -p ${SIDETREE_OUTPUT_DIR}

cat > ${SIDETREE_OUTPUT_DIR}/stakeholder-one_jwk.json <<EOF
{
  "kty": "OKP",
  "kid": "key1",
  "d": "CSLczqR1ly2lpyBcWne9gFKnsjaKJw0dKfoSQu7lNvg",
  "crv": "Ed25519",
  "x": "bWRCy8DtNhRO3HdKTFB2eEG5Ac1J00D0DQPffOwtAD0"
}
EOF

cat > ${SIDETREE_OUTPUT_DIR}/testnet.json <<EOF
{
  "consortiumData": {
    "domain": "testnet.${DOMAIN}",
    "genesisBlock": "6e2f978e16b59df1d6a1dfbacb92e7d3eddeb8b3fd825e573138b3fd77d77264",
    "policy": {
      "cache": {
        "maxAge": 600
      },
      "numQueries": 1
    }
  },
  "membersData": [
    {
      "domain": "stakeholder-one.${DOMAIN}",
      "policy": {
        "cache": {
          "maxAge": 300
        }
      },
      "endpoints": [
        "https://sidetree-mock.${DOMAIN}/sidetree/v1"
      ],
      "privateKeyJwkPath": "/config-data/stakeholder-one_jwk.json"
    }
  ]
}
EOF
