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
export BLOC_DOMAIN      		?= testnet.${DOMAIN}
export COUCHDB_URL								?= cdbadmin:secret@couchdb:5984

OS 				= $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH  				= $(shell uname -m | sed 's/x86_64/amd64/')

#IMAGES
KMS_IMG				?= ghcr.io/trustbloc-cicd/kms:0.1.7-snapshot-6aeea55
OATHKEEPER_IMG			?= oryd/oathkeeper:v0.38.4-alpine

# do not modify
KUSTOMIZE_DIR       	= kustomize/kms
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
		--entrypoint "/opt/workspace/scripts/generate_lock_test_key.sh" \
		docker.io/frapsoft/openssl:latest

.PHONY: deploy
deploy: prechecks kustomize set-images set-labels deploy-authz-kms deploy-ops-kms deploy-vault-kms deploy-orb1-kms deploy-orb2-kms

.PHONY: prechecks
prechecks:
ifeq (, $(shell stat ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV} 2>/dev/null))
	@echo "Environment not found ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}"
	@exit 1
endif

.PHONY: set-labels
set-labels: kustomize set-labels-authz-kms set-labels-ops-kms set-labels-vault-kms set-labels-orb1-kms set-labels-orb2-kms

.PHONY: set-labels-authz-kms
set-labels-authz-kms: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/authz-kms &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd
.PHONY: set-labels-ops-kms
set-labels-ops-kms: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/ops-kms &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-labels-vault-kms
set-labels-vault-kms: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vault-kms &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-labels-orb1-kms
set-labels-orb1-kms: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb1-kms &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-labels-orb2-kms
set-labels-orb2-kms: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb2-kms &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-images
set-images: kustomize
	@pushd ${KUSTOMIZE_DIR}/base &&\
	${KUSTOMIZE} edit set image kms=${KMS_IMG} &&\
	popd
	@pushd ${KUSTOMIZE_DIR}/components/oathkeeper &&\
	${KUSTOMIZE} edit set image oathkeeper=${OATHKEEPER_IMG} &&\
	popd

.PHONY: deploy-authz-kms
deploy-authz-kms: prechecks set-images set-labels-authz-kms kustomize
	@docker pull $(KMS_IMG)
	@minikube image load $(KMS_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/authz-kms | kubectl apply -f -

.PHONY: deploy-ops-kms
deploy-ops-kms: prechecks set-images set-labels-ops-kms kustomize
	@docker pull $(KMS_IMG)
	@minikube image load $(KMS_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/ops-kms | kubectl apply -f -

.PHONY: deploy-vault-kms
deploy-vault-kms: prechecks set-images set-labels-vault-kms kustomize
	@docker pull $(KMS_IMG)
	@minikube image load $(KMS_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vault-kms | kubectl apply -f -


.PHONY: deploy-orb1-kms
deploy-orb1-kms: prechecks set-images set-labels-orb1-kms kustomize
	@docker pull $(KMS_IMG)
	@minikube image load $(KMS_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb1-kms | kubectl apply -f -


.PHONY: deploy-orb2-kms
deploy-orb2-kms: prechecks set-images set-labels-orb2-kms kustomize
	@docker pull $(KMS_IMG)
	@minikube image load $(KMS_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb2-kms | kubectl apply -f -


.PHONY: undeploy
undeploy: prechecks kustomize set-images set-labels undeploy-authz-kms undeploy-ops-kms undeploy-vault-kms undeploy-orb1-kms undeploy-orb2-kms

.PHONY: undeploy-authz-kms
undeploy-authz-kms: prechecks set-images set-labels-authz-kms kustomize
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/authz-kms | kubectl delete -f -

.PHONY: undeploy-ops-kms
undeploy-ops-kms: prechecks set-images set-labels-ops-kms kustomize
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/ops-kms | kubectl delete -f -

.PHONY: undeploy-vault-kms
undeploy-vault-kms: prechecks set-images set-labels-vault-kms kustomize
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vault-kms | kubectl delete -f -

.PHONY: undeploy-orb1-kms
undeploy-orb1-kms: prechecks set-images set-labels-orb1-kms kustomize
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb1-kms | kubectl delete -f -

.PHONY: undeploy-orb2-kms
undeploy-orb2-kms: prechecks set-images set-labels-orb2-kms kustomize
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb2-kms | kubectl delete -f -



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
