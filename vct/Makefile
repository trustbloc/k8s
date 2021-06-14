#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

SHELL                           := /bin/bash
CONTAINER_CMD         	 	    ?= docker
USER_ID                         = $(shell id -u)
DOCKER_CMD_RUN_OPTS             ?= -u $(USER_ID)
CONTAINER_CMD_RUN_OPTS          ?= $(if $(findstring docker,$(CONTAINER_CMD)),$(DOCKER_CMD_RUN_OPTS),)

export DEPLOYMENT_ENV		    ?= local
# space delimited of Key:Value pairs
COMMON_LABELS					:= instance:${DEPLOYMENT_ENV}
export DOMAIN      				?= ${DEPLOYMENT_ENV}.trustbloc.dev
export BLOC_DOMAIN      		?= testnet.${DOMAIN}
export COUCHDB_URL				?= couchdb://cdbadmin:secret@couchdb:5984

OS 								= $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH  							= $(shell uname -m | sed 's/x86_64/amd64/')

#IMAGES
VCT_IMG	 						?= ghcr.io/trustbloc-cicd/vct:v0.1.0-snapshot-f1185c0

export TRILLIAN1_LOG_MYSQL		?= orb1vct:orb1vct-secret-pw@tcp(mysql:3306)/orb1vct
export TRILLIAN2_LOG_MYSQL		?= orb2vct:orb2vct-secret-pw@tcp(mysql:3306)/orb2vct
export TRILLIAN3_LOG_MYSQL		?= orb3vct:orb3vct-secret-pw@tcp(mysql:3306)/orb3vct


# do not modify
KUSTOMIZE_DIR       			= kustomize/vct
CERTS_OUTPUT_DIR      	 	    = ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/certs
PREFIX							?=
KUSTOMIZE_BUILD_OPTS			?= --load-restrictor LoadRestrictionsNone --enable-alpha-plugins
export KUSTOMIZE_PLUGIN_HOME	= $(abspath .)/kustomize/plugin

.PHONY: all
all: setup

.PHONY: setup
setup: generate-test-certs
	@echo setup

.PHONY: setup-no-certs
setup-no-certs:
	@echo setup-no-certs

.PHONY: deploy
deploy: prechecks kustomize kubectl set-images set-labels deploy-vct1 deploy-vct2 deploy-vct3

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

.PHONY: prechecks
prechecks:
ifeq (, $(shell stat ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV} 2>/dev/null))
	@echo "Environment not found ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}"
	@exit 1
endif

.PHONY: set-labels
set-labels: kustomize set-labels-vct1 set-labels-vct2 set-labels-vct3

.PHONY: set-labels-vct1
set-labels-vct1: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vct1 &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-labels-vct2
set-labels-vct2: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vct2 &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-labels-vct3
set-labels-vct3: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vct3 &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-images
set-images: kustomize
	@pushd ${KUSTOMIZE_DIR}/base &&\
	${KUSTOMIZE} edit set image vct=${VCT_IMG} &&\
	popd

.PHONY: deploy-vct1
deploy-vct1: prechecks set-images set-labels-vct1 kustomize kubectl
	@docker pull $(VCT_IMG)
	@minikube image load $(VCT_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vct1 | $(KUBECTL) apply -f -

.PHONY: deploy-vct2
deploy-vct2: prechecks set-images set-labels-vct2 kustomize kubectl
	@docker pull $(VCT_IMG)
	@minikube image load $(VCT_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vct2 | $(KUBECTL) apply -f -

.PHONY: deploy-vct3
deploy-vct3: prechecks set-images set-labels-vct3 kustomize kubectl
	@docker pull $(VCT_IMG)
	@minikube image load $(VCT_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vct3 | $(KUBECTL) apply -f -


.PHONY: undeploy
undeploy: prechecks kustomize kubectl set-images set-labels undeploy-vct1 undeploy-vct2 undeploy-vct3

.PHONY: undeploy-vct1
undeploy-vct1: prechecks set-images set-labels-vct1 kustomize kubectl
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vct1 | $(KUBECTL) delete -f -

.PHONY: undeploy-vct2
undeploy-vct2: prechecks set-images set-labels-vct2 kustomize kubectl
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vct2 | $(KUBECTL) delete -f -

.PHONY: undeploy-vct3
undeploy-vct3: prechecks set-images set-labels-vct3 kustomize kubectl
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/vct3 | $(KUBECTL) delete -f -

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

.PHONY: kubectl
kubectl:
ifeq (, $(shell which kubectl 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p bin ;\
	curl -sSL https://storage.googleapis.com/kubernetes-release/release/v1.20.4/bin/$(OS)/$(ARCH)/kubectl -o bin/kubectl ;\
  chmod u+x bin/kubectl ;\
	}
KUBECTL=$(realpath ./bin/kubectl)
else
KUBECTL=$(shell which kubectl)
endif

.PHONY: clean
clean: clean-all

.PHONY: clean-all
clean-all: clean-certs

.PHONY: clean-certs
clean-certs:
	@rm -Rf ${CERTS_OUTPUT_DIR}
