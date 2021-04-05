# 
# Copyright SecureKey Technologies Inc. All Rights Reserved. 
# 
# SPDX-License-Identifier: Apache-2.0 
# 


CONTAINER_CMD      	 	?= docker
USER_ID                          = $(shell id -u)
DOCKER_CMD_RUN_OPTS            ?= -u $(USER_ID)
CONTAINER_CMD_RUN_OPTS         ?= $(if $(findstring docker,$(CONTAINER_CMD)),$(DOCKER_CMD_RUN_OPTS),)

export DEPLOYMENT_ENV	?= local
# space delimited of Key:Value pairs
COMMON_LABELS		:= instance:${DEPLOYMENT_ENV}
export DOMAIN      	?= trustbloc.dev
export BLOC_DOMAIN      	?= testnet.trustbloc.dev

OS    				= $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH  				= $(shell uname -m | sed 's/x86_64/amd64/')

#IMAGES
SIDETREE_MOCK_IMG	 	?= ghcr.io/trustbloc/sidetree-mock:0.6.0
STATIC_FILE_SERVER_IMG	 	?= halverneus/static-file-server:v1.8.2
DID_METHOD_CLI_IMG		?= ghcr.io/trustbloc/did-method-cli:0.1.6

# do not modify
KUSTOMIZE_DIR       	= kustomize/sidetree-mock
KEYS_OUTPUT_DIR        	 	= ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/keys
CERTS_OUTPUT_DIR       	 	= ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/certs
export SIDETREE_OUTPUT_DIR   	= ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/sidetree
REGISTRY_DIRECTORY           	= ${KUSTOMIZE_DIR}/base/registry
KUSTOMIZE_BUILD_OPTS			?= --load-restrictor LoadRestrictionsNone --enable-alpha-plugins
export KUSTOMIZE_PLUGIN_HOME						= $(abspath .)/kustomize/plugin

.PHONY: all
all: setup

.PHONY: setup
setup: generate-test-keys generate-test-certs seed-sidetree-mock
	@echo setup

.PHONY: setup-no-certs
setup-no-certs: generate-test-keys seed-sidetree-mock
	@echo setup-no-certs

.PHONY: generate-test-keys
generate-test-keys: clean-keys
	@echo $(abspath .)
	@$(CONTAINER_CMD) run ${CONTAINER_CMD_RUN_OPTS} -i --rm \
		-v $(abspath .):/opt/workspace:Z \
		-e KEYS_OUTPUT_DIR=${KEYS_OUTPUT_DIR} \
		--entrypoint "/opt/workspace/scripts/generate_test_keys.sh" \
		docker.io/frapsoft/openssl:latest

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

.PHONY: seed-sidetree-mock
seed-sidetree-mock: clean-sidetree
	@scripts/seed_sidetree_mock.sh

.PHONY: deploy
deploy: prechecks kustomize set-images set-labels deploy-sidetree-mock

.PHONY: prechecks
prechecks:
ifeq (, $(shell stat ${REGISTRY_DIRECTORY}/.dockerconfigjson 2>/dev/null))
	@echo "docker registry config not found: ${REGISTRY_DIRECTORY}/.dockerconfigjson"
	@exit 1
else ifeq (, $(shell stat ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV} 2>/dev/null))
	@echo "Environment not found ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}"
	@exit 1
endif

.PHONY: set-labels
set-labels: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV} &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-images
set-images: kustomize
	@pushd ${KUSTOMIZE_DIR}/base &&\
	${KUSTOMIZE} edit set image sidetree-mock=${SIDETREE_MOCK_IMG} &&\
	popd &&\
	pushd ${KUSTOMIZE_DIR}/components/static-file-server &&\
	${KUSTOMIZE} edit set image static-file-server=${STATIC_FILE_SERVER_IMG} &&\
	popd &&\
	pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV} &&\
	${KUSTOMIZE} edit set image did-method-cli=${DID_METHOD_CLI_IMG} &&\
	popd

.PHONY: deploy-sidetree-mock
deploy-sidetree-mock: prechecks kustomize
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV} | kubectl apply -f -

.PHONY: undeploy
undeploy: prechecks kustomize set-images set-labels undeploy-sidetree-mock

.PHONY: undeploy-sidetree-mock
undeploy-sidetree-mock: prechecks kustomize
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV} | kubectl delete -f -

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
clean-all: clean-sidetree clean-keys clean-certs clean-registry

.PHONY: clean-no-certs-registry
clean-no-certs-registry: clean-sidetree clean-keys

.PHONY: clean-sidetree
clean-sidetree:
	@rm -Rf ${SIDETREE_OUTPUT_DIR}

.PHONY: clean-keys
clean-keys:
	@rm -Rf ${KEYS_OUTPUT_DIR}

.PHONY: clean-certs
clean-certs:
	@rm -Rf ${CERTS_OUTPUT_DIR}

.PHONY: clean-registry
clean-registry:
	@rm -Rf ${REGISTRY_DIRECTORY}
