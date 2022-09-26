#!/bin/sh
#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

echo "Generating KMS encryption key ..."
export RANDFILE=/tmp/rnd

if [ "${KEYS_OUTPUT_DIR}x" == "x" ]; then
    echo "KEYS_OUTPUT_DIR env not set"
    exit 1
fi

cd /opt/workspace

mkdir -p ${KEYS_OUTPUT_DIR}

# create private key for KMS encryption
openssl rand 32 | base64 | sed 's/+/-/g; s/\//_/g' > ${KEYS_OUTPUT_DIR}/vcs-kms-key.pem

echo "... Done generating KMS encryption key ${KEYS_OUTPUT_DIR}"
