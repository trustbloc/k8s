#!/bin/sh
#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

echo "Generating test key ..."
export RANDFILE=/tmp/rnd

if [ "${KEYS_OUTPUT_DIR}x" == "x" ]; then
    echo "KEYS_OUTPUT_DIR env not set"
    exit 1
fi

cd /opt/workspace

mkdir -p ${KEYS_OUTPUT_DIR}


# authz-kms create secret lock key
openssl rand 32 | base64 | sed 's/+/-/g; s/\//_/g' > ${KEYS_OUTPUT_DIR}/authz-kms-secret-lock.key
# ops-kms create secret lock key
openssl rand 32 | base64 | sed 's/+/-/g; s/\//_/g' > ${KEYS_OUTPUT_DIR}/ops-kms-secret-lock.key
# vault-kms create secret lock key
openssl rand 32 | base64 | sed 's/+/-/g; s/\//_/g' > ${KEYS_OUTPUT_DIR}/vault-kms-secret-lock.key
# orb-kms create secret lock key
openssl rand 32 | base64 | sed 's/+/-/g; s/\//_/g' > ${KEYS_OUTPUT_DIR}/orb-kms-secret-lock.key

echo "... Done generating test keys"
