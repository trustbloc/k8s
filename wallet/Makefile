#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#


CONTAINER_CMD         	 	?= docker
USER_ID                          = $(shell id -u)
DOCKER_CMD_RUN_OPTS            ?= -u $(USER_ID)
CONTAINER_CMD_RUN_OPTS         ?= $(if $(findstring docker,$(CONTAINER_CMD)),$(DOCKER_CMD_RUN_OPTS),)

export DEPLOYMENT_ENV	?= local
# space delimited of Key:Value pairs
COMMON_LABELS		:= instance:${DEPLOYMENT_ENV}
export DOMAIN      		?= ${DEPLOYMENT_ENV}.trustbloc.dev
export BLOC_DOMAIN		?= testnet.${DOMAIN}
export ARIESD_DATABASE_URL								?= edgeagent:edgeagent-secret-pw@tcp(mysql:3306)/
export HUB_ROUTER_DSN_PERSISTENT			?= mysql://hubrouter:hubrouter-secret-pw@tcp(mysql:3306)/
export HUB_ROUTER_DSN_TRANSIENT				?= mysql://hubrouter:hubrouter-secret-pw@tcp(mysql:3306)/

OS 				= $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH  				= $(shell uname -m | sed 's/x86_64/amd64/')

#IMAGES
WALLET_WEB_IMG				?= ghcr.io/trustbloc-cicd/wallet-web:0.1.7-snapshot-8649cdc
WALLET_SERVER_IMG			?= ghcr.io/trustbloc-cicd/wallet-server:0.1.7-snapshot-8649cdc
HUB_ROUTER_IMG				?= ghcr.io/trustbloc-cicd/hub-router:0.1.7-snapshot-3a56649

# do not modify
KUSTOMIZE_DIR       	= kustomize/wallet
KEYS_OUTPUT_DIR        	 	= ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/keys
CERTS_OUTPUT_DIR      	 	= ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/certs
REGISTRY_DIRECTORY           	= ${KUSTOMIZE_DIR}/base/registry
PREFIX							?=
KUSTOMIZE_BUILD_OPTS			?= --load-restrictor LoadRestrictionsNone --enable-alpha-plugins
export KUSTOMIZE_PLUGIN_HOME						= $(abspath .)/kustomize/plugin

.PHONY: all
all: setup

.PHONY: setup
setup: generate-test-certs generate-test-keys
	@echo setup

.PHONY: setup-no-certs
setup-no-certs: generate-test-keys
	@echo setup-no-certs

.PHONY: generate-test-certs
generate-test-certs: clean-certs
	@echo $(abspath .)
	@$(CONTAINER_CMD) run ${CONTAINER_CMD_RUN_OPTS} -i --rm \
		-v $(abspath .):/opt/workspace:Z \
		-e DOMAIN=${DOMAIN} \
		-e CERTS_OUTPUT_DIR=${CERTS_OUTPUT_DIR} \
		--entrypoint "/opt/workspace/scripts/generate_test_certs.sh" \
		docker.io/frapsoft/openssl:latest
	@cd ${CERTS_OUTPUT_DIR} && ln -fs trustbloc-dev-ca.crt ca.crt
	@cd ${CERTS_OUTPUT_DIR} && ln -fs ${DOMAIN}.key tls.key
	@cd ${CERTS_OUTPUT_DIR} && ln -fs ${DOMAIN}.crt tls.crt

.PHONY: generate-test-keys
generate-test-keys: clean-keys
	@echo $(abspath .)
	@$(CONTAINER_CMD) run ${CONTAINER_CMD_RUN_OPTS} -i --rm \
		-v $(abspath .):/opt/workspace:Z \
		-e KEYS_OUTPUT_DIR=${KEYS_OUTPUT_DIR} \
		--entrypoint "/opt/workspace/scripts/generate_test_keys.sh" \
		docker.io/frapsoft/openssl:latest

.PHONY: deploy
deploy: prechecks kustomize set-images set-labels deploy-wallet

.PHONY: prechecks
prechecks:
ifeq (, $(shell stat ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV} 2>/dev/null))
	@echo "Environment not found ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}"
	@exit 1
endif

.PHONY: set-labels
set-labels: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/wallet &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-images
set-images: kustomize
	@pushd ${KUSTOMIZE_DIR}/base &&\
	${KUSTOMIZE} edit set image wallet-web=${WALLET_WEB_IMG} &&\
	${KUSTOMIZE} edit set image wallet-server=${WALLET_SERVER_IMG} &&\
	${KUSTOMIZE} edit set image hub-router=${HUB_ROUTER_IMG} &&\
	popd

.PHONY: deploy-wallet
deploy-wallet: prechecks kustomize
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/wallet | kubectl apply -f -

.PHONY: undeploy
undeploy: prechecks kustomize set-images set-labels undeploy-wallet

.PHONY: undeploy-wallet
undeploy-wallet: prechecks kustomize
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/wallet | kubectl delete -f -

.PHONY: kustomize
kustomize:
ifeq (, $(shell which kustomize 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p bin ;\
	curl -sSLo - https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v4.0.4/kustomize_v4.0.4_$(OS)_$(ARCH).tar.gz | tar xzf - -C bin/ ;\
	}
KUSTOMIZE=$(realpath ./bin/kustomize)
else
KUSTOMIZE=$(shell which kustomize)
endif

.PHONY: clean
clean: clean-all

.PHONY: clean-all
clean-all: clean-certs clean-keys clean-registry

.PHONY: clean-no-registry
clean-no-registry: clean-certs clean-keys

.PHONY: clean-keys
clean-keys:
	@rm -Rf ${KEYS_OUTPUT_DIR}

.PHONY: clean-certs
clean-certs:
	@rm -Rf ${CERTS_OUTPUT_DIR}

.PHONY: clean-registry
clean-registry:
	@rm -Rf ${REGISTRY_DIRECTORY}
