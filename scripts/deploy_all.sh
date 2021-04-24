#!/usr/bin/env bash
#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

## Run minikube setup before the local deployment
# bash minikube_setup.sh

## Default values, will be overriden by the existing env variable value
: ${DOMAIN:=trustbloc.dev}
: ${DEPLOYMENT_ENV:=local}
## Should be deployed in the listed order
: ${COMPONENTS=sidetree-mock edv resolver registrar csh vcs vault-server kms hub-auth wallet adapters}
DEPLOY_LIST=( $COMPONENTS )

## Map: component --> healthcheck(s)
declare -A HEALTCHECK_URL=(
    [sidetree-mock]="https://sidetree-mock.$DOMAIN https://testnet.$DOMAIN/.well-known/did-orb"
    [edv]="https://edv-oathkeeper-proxy.$DOMAIN/healthcheck"
    [resolver]="https://did-resolver.$DOMAIN/healthcheck https://uni-resolver-web.$DOMAIN/1.0/identifiers/did:elem:EiAS3mqC4OLMKOwcz3ItIL7XfWduPT7q3Fa4vHgiCfSG2A"
    [registrar]="https://uni-registrar-web.$DOMAIN/1.0/register"
    [csh]="https://csh.$DOMAIN/healthcheck"
    [vcs]="https://issuer-vcs.$DOMAIN/healthcheck https://verifier-vcs.$DOMAIN/healthcheck https://holder-vcs.$DOMAIN/healthcheck https://governance-vcs.$DOMAIN/healthcheck"
    [vault-server]="https://vault-server.$DOMAIN/healthcheck"
    [kms]="https://authz-oathkeeper-proxy.$DOMAIN/healthcheck https://ops-oathkeeper-proxy.$DOMAIN/healthcheck https://vault-kms.$DOMAIN/healthcheck"
    [hub-auth]="https://hub-auth.$DOMAIN/healthcheck"
    [wallet]="https://router-api.$DOMAIN/healthcheck https://wallet.$DOMAIN/healthcheck https://wallet-support.$DOMAIN/healthcheck"
    [adapters]="https://adapter-rp.$DOMAIN/healthcheck https://adapter-issuer.$DOMAIN/healthcheck"
)
## Map: healthckeck --> http-code
declare -A HEALTHCHECK_CODE=(
    [https://testnet.$DOMAIN/.well-known/did-orb]=200
    [https://sidetree-mock.$DOMAIN]=404
    [https://edv-oathkeeper-proxy.$DOMAIN/healthcheck]=200
    [https://did-resolver.$DOMAIN/healthcheck]=200
    [https://uni-resolver-web.$DOMAIN/1.0/identifiers/did:elem:EiAS3mqC4OLMKOwcz3ItIL7XfWduPT7q3Fa4vHgiCfSG2A]=200
    [https://uni-registrar-web.$DOMAIN/1.0/register]=405
    [https://issuer-vcs.$DOMAIN/healthcheck]=200
    [https://verifier-vcs.$DOMAIN/healthcheck]=200
    [https://holder-vcs.$DOMAIN/healthcheck]=200
    [https://governance-vcs.$DOMAIN/healthcheck]=200
    [https://vault-server.$DOMAIN/healthcheck]=200
    [https://csh.$DOMAIN/healthcheck]=200
    [https://authz-oathkeeper-proxy.$DOMAIN/healthcheck]=200
    [https://ops-oathkeeper-proxy.$DOMAIN/healthcheck]=200
    [https://vault-kms.$DOMAIN/healthcheck]=200
    [https://router-api.$DOMAIN/healthcheck]=200
    [https://hub-auth.$DOMAIN/healthcheck]=200
    [https://wallet.$DOMAIN/healthcheck]=200
    [https://wallet-support.$DOMAIN/healthcheck]=200
    [https://adapter-rp.$DOMAIN/healthcheck]=200
    [https://adapter-issuer.$DOMAIN/healthcheck]=200
)

# healthCheck function -- copied from sandbox
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
AQUA=$(tput setaf 6)
NONE=$(tput sgr0)
healthCheck() {
	sleep 2
	n=0
	maxAttempts=200
	echo "running health check : app=$1 url=$2 timeout=$maxAttempts seconds"
	until [ $n -ge $maxAttempts ]
	do
	  response=$(curl -H 'Cache-Control: no-cache' -o /dev/null -s -w "%{http_code}" --insecure "$2")
	   if [ "$response" == "$3" ]
	   then
		 echo "${GREEN}$1 $2 is up ${NONE}"
		 break
	   fi
	   n=$((n+1))
	   if [ $n -eq $maxAttempts ]
	   then
		 echo "${RED}failed health check : app=$1 url=$2 responseCode=$response ${NONE}"
	   fi
	   sleep 1
	done
}

## deploy the DBs dependency first
pushd dbs
    make
popd
### TODO: set up proper mysql, couchDB healthchecks
echo wait for DBs to start up
while [[ `kubectl get po | grep Running |wc -l` -lt 2 ]]; do
    sleep 1
done
# healthCheck couchdb $couchdbHealthCheckURL 200
# checkMYSQLDB rpadapter_hydra
# checkMYSQLDB authresthydra
# checkMYSQLDB edgeagent_aries

## generate certificate for all components, skip if already exists
if ! [[ -d ~/.trustbloc-k8s/${DEPLOYMENT_ENV}/certs ]]; then
pushd sidetree-mock
    make generate-test-certs
    mkdir -p ~/.trustbloc-k8s/${DEPLOYMENT_ENV}/certs
    mv kustomize/sidetree-mock/overlays/${DEPLOYMENT_ENV}/certs ~/.trustbloc-k8s/${DEPLOYMENT_ENV}/
popd
fi

for component in ${DEPLOY_LIST[@]}; do
    echo "${AQUA} === component: $component ${NONE}"
    pushd $component
        make setup-no-certs
        mkdir -p kustomize/$component/overlays/${DEPLOYMENT_ENV}/certs
        cp ~/.trustbloc-k8s/${DEPLOYMENT_ENV}/certs/* kustomize/$component/overlays/${DEPLOYMENT_ENV}/certs
        make deploy
    popd
    ## run all health checks for a given component
    for url in ${HEALTCHECK_URL[$component]}; do
        healthCheck $component "$url" ${HEALTHCHECK_CODE["$url"]}
    done
#    echo press ENTER to continue && read L
done
