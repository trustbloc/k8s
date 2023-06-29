#
# Copyright SecureKey Technologies Inc.
#
# SPDX-License-Identifier: Apache-2.0
#

export DOMAIN			?= ${DEPLOYMENT_ENV}.trustbloc.dev
export DEPLOYMENT_ENV	?= local
COMPONENTS				?=

OS 								= $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH  							= $(shell uname -m | sed 's/x86_64/amd64/')

.PHONY: all checks license deploy-all kustomize deploy-components setup-and-deploy minikube-setup minikube-reset

all: checks

checks: license

license:
	@scripts/check_license.sh

deploy-all:
	./scripts/deploy_all.sh

kustomize:
	@{ \
	curl -sSLo - https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v4.3.0/kustomize_v4.3.0_$(OS)_$(ARCH).tar.gz | tar xzf - -C /usr/local/bin ;\
	}

deploy-components:
	COMPONENTS="$(COMPONENTS)" ./scripts/deploy_all.sh

setup-and-deploy: minikube-reset
	@echo "Apply/verify the required changes to /etc/hosts. Once done, press ENTER" && read L
	./scripts/deploy_all.sh

minikube-setup:
	cd scripts && ./minikube_setup.sh

minikube-reset:
	cd scripts && minikube delete ; ./minikube_setup.sh
