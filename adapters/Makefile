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
export ISSUER_ADAPTER_REST_DSN								?= mysql://issueradapter:issueradapter-secret-pw@tcp(mysql:3306)/
export RP_ADAPTER_REST_DSN								?= mysql://rpadapter:rpadapter-secret-pw@tcp(mysql:3306)/
export HYDRA_MYSQL_DSN								?= mysql://rpadapterhydra:secret@tcp(mysql:3306)/rpadapter_hydra?max_conns=20&max_idle_conns=4

OS 				= $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH  				= $(shell uname -m | sed 's/x86_64/amd64/')

#IMAGES
ISSUER_ADAPTER_IMG				?= ghcr.io/trustbloc-cicd/issuer-adapter:0.1.7-snapshot-813410f
RP_ADAPTER_IMG						?= ghcr.io/trustbloc-cicd/rp-adapter:0.1.7-snapshot-813410f
HYDRA_IMG			?= oryd/hydra:v1.3.2-alpine

# do not modify
KUSTOMIZE_DIR       	= kustomize/adapters
CERTS_OUTPUT_DIR      	 	= ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/certs
KEYS_OUTPUT_DIR						= ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/keys
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
		--entrypoint "/opt/workspace/scripts/generate_issuer_test_key.sh" \
		docker.io/frapsoft/openssl:latest

.PHONY: deploy
deploy: prechecks kustomize set-images set-labels deploy-adapters

.PHONY: prechecks
prechecks:
ifeq (, $(shell stat ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV} 2>/dev/null))
	@echo "Environment not found ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}"
	@exit 1
endif

.PHONY: set-labels
set-labels: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/adapters &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-images
set-images: kustomize
	@pushd ${KUSTOMIZE_DIR}/base &&\
	${KUSTOMIZE} edit set image issuer-adapter=${ISSUER_ADAPTER_IMG} &&\
	${KUSTOMIZE} edit set image rp-adapter=${RP_ADAPTER_IMG} &&\
	popd
	@pushd ${KUSTOMIZE_DIR}/components/hydra &&\
	${KUSTOMIZE} edit set image hydra=${HYDRA_IMG} &&\
	popd

.PHONY: deploy-adapters
deploy-adapters: prechecks kustomize
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/adapters | kubectl apply -f -

.PHONY: undeploy
undeploy: prechecks kustomize set-images set-labels undeploy-adapters

.PHONY: undeploy-adapters
undeploy-adapters: prechecks kustomize
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/adapters | kubectl delete -f -

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
