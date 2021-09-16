#
# Copyright SecureKey Technologies Inc. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

SHELL                       := /bin/bash
CONTAINER_CMD         	 	?= docker
USER_ID                          = $(shell id -u)
DOCKER_CMD_RUN_OPTS            ?= -u $(USER_ID)
CONTAINER_CMD_RUN_OPTS         ?= $(if $(findstring docker,$(CONTAINER_CMD)),$(DOCKER_CMD_RUN_OPTS),)

export DEPLOYMENT_ENV	?= local
# space delimited of Key:Value pairs
COMMON_LABELS		            := instance:${DEPLOYMENT_ENV}
export DOMAIN      		        ?= ${DEPLOYMENT_ENV}.trustbloc.dev
export BLOC_DOMAIN      		?= orb-1.${DOMAIN}
export ORB_1_MONGODB_URL				?= mongodb://mongoroot:secret@mongodb-orb-1:27017
export ORB_2_MONGODB_URL				?= mongodb://mongoroot:secret@mongodb-orb-2:27017
export ORB_3_MONGODB_URL				?= mongodb://mongoroot:secret@mongodb-orb-3:27017
export ORB_4_MONGODB_URL				?= mongodb://mongoroot:secret@mongodb-orb-4:27017
export ORB_AUTH_TOKENS			?= admin=ADMIN_TOKEN
export MQ_USER					?= admin
export MQ_PASSWORD				?= password
export MQ_URL_1						?= amqp://admin:password@mq-1:5672/
export MQ_URL_2						?= amqp://admin:password@mq-2:5672/
export MQ_URL_3						?= amqp://admin:password@mq-3:5672/
export MQ_URL_4						?= amqp://admin:password@mq-4:5672/


OS 				= $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH  				= $(shell uname -m | sed 's/x86_64/amd64/')

#IMAGES
ORB_IMG	 	?= ghcr.io/trustbloc/orb:v0.1.3

# do not modify
KUSTOMIZE_DIR       	= kustomize/orb
CERTS_OUTPUT_DIR      	 	= ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/certs
PREFIX							?=
KUSTOMIZE_BUILD_OPTS			?= --load-restrictor LoadRestrictionsNone --enable-alpha-plugins
export KUSTOMIZE_PLUGIN_HOME						= $(abspath .)/kustomize/plugin

.PHONY: all
all: setup

.PHONY: setup
setup: generate-test-certs
	@echo setup

.PHONY: setup-no-certs
setup-no-certs:
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

.PHONY: deploy
deploy: prechecks kustomize kubectl set-images set-labels deploy-orb1 deploy-orb2 deploy-orb3 deploy-orb4 deploy-orb-setup

.PHONY: prechecks
prechecks:
ifeq (, $(shell stat ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV} 2>/dev/null))
	@echo "Environment not found ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}"
	@exit 1
endif

.PHONY: set-labels
set-labels: kustomize set-labels-orb1 set-labels-orb2 set-labels-orb3 set-labels-orb4

.PHONY: set-labels-orb1
set-labels-orb1: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb1 &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-labels-orb2
set-labels-orb2: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb2 &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-labels-orb3
set-labels-orb3: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb3 &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-labels-orb4
set-labels-orb4: kustomize
	@pushd ${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb4 &&\
		${KUSTOMIZE} edit set label ${COMMON_LABELS} &&\
		popd

.PHONY: set-images
set-images: kustomize
	@pushd ${KUSTOMIZE_DIR}/base &&\
	${KUSTOMIZE} edit set image orb=${ORB_IMG} &&\
	popd

.PHONY: deploy-orb1
deploy-orb1: prechecks set-images set-labels-orb1 kustomize kubectl
	@docker pull $(ORB_IMG)
	@minikube image load $(ORB_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb1 | $(KUBECTL) apply -f -

.PHONY: deploy-orb2
deploy-orb2: prechecks set-images set-labels-orb2 kustomize kubectl
	@docker pull $(ORB_IMG)
	@minikube image load $(ORB_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb2 | $(KUBECTL) apply -f -

.PHONY: deploy-orb3
deploy-orb3: prechecks set-images set-labels-orb3 kustomize kubectl
	@docker pull $(ORB_IMG)
	@minikube image load $(ORB_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb3 | $(KUBECTL) apply -f -

.PHONY: deploy-orb4
deploy-orb4: prechecks set-images set-labels-orb4 kustomize kubectl
	@docker pull $(ORB_IMG)
	@minikube image load $(ORB_IMG)
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb4 | $(KUBECTL) apply -f -


.PHONY: deploy-orb-setup
deploy-orb-setup: prechecks set-images kustomize kubectl
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/setup | $(KUBECTL) apply -f -

.PHONY: undeploy
undeploy: prechecks kustomize kubectl set-images set-labels undeploy-orb1 undeploy-orb2 undeploy-orb3 undeploy-orb-setup

.PHONY: undeploy-orb1
undeploy-orb1: prechecks set-images set-labels-orb1 kustomize kubectl
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb1 | kubectl delete -f -

.PHONY: undeploy-orb2
undeploy-orb2: prechecks set-images set-labels-orb2 kustomize kubectl
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb2 | kubectl delete -f -

.PHONY: undeploy-orb3
undeploy-orb3: prechecks set-images set-labels-orb3 kustomize kubectl
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb3 | kubectl delete -f -

.PHONY: undeploy-orb4
undeploy-orb4: prechecks set-images set-labels-orb4 kustomize kubectl
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/orb4 | kubectl delete -f -

.PHONY: undeploy-orb-setup
undeploy-orb-setup: prechecks set-images kustomize kubectl
	$(KUSTOMIZE) build ${KUSTOMIZE_BUILD_OPTS} \
	${KUSTOMIZE_DIR}/overlays/${DEPLOYMENT_ENV}/setup | kubectl delete -f -


.PHONY: kustomize
kustomize:
ifeq (, $(shell which kustomize 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p bin ;\
	curl -sSLo - https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v4.3.0/kustomize_v4.3.0_$(OS)_$(ARCH).tar.gz | tar xzf - -C bin/ ;\
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
