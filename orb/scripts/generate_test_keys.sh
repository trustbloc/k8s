#!/bin/sh
#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

echo "Generating test keys ..."
export RANDFILE=/tmp/rnd

if [ "${KEYS_OUTPUT_DIR}x" == "x" ]; then
    echo "KEYS_OUTPUT_DIR env not set"
    exit 1
fi

cd /opt/workspace

mkdir -p ${KEYS_OUTPUT_DIR}

# generate key pair for recover/updates
openssl ecparam -name prime256v1 -genkey -noout -out ${KEYS_OUTPUT_DIR}/recover_private.pem
openssl ec -in ${KEYS_OUTPUT_DIR}/recover_private.pem -pubout -out ${KEYS_OUTPUT_DIR}/recover_public.pem
openssl ecparam -name prime256v1 -genkey -noout -out ${KEYS_OUTPUT_DIR}/update_private.pem
openssl ec -in ${KEYS_OUTPUT_DIR}/update_private.pem -pubout -out ${KEYS_OUTPUT_DIR}/update_public.pem

echo "... Done generating test keys"
