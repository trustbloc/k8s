#
# Copyright SecureKey Technologies Inc.
#
# SPDX-License-Identifier: Apache-2.0
#

export DOMAIN			?= ${DEPLOYMENT_ENV}.trustbloc.dev
export DEPLOYMENT_ENV	?= local
COMPONENTS				?=

.PHONY: all checks license deploy-all deploy-components setup-and-deploy minikube-setup minikube-reset

all: checks

checks: license

license:
	@scripts/check_license.sh

deploy-all:
	./scripts/deploy_all.sh

deploy-components:
	COMPONENTS="$(COMPONENTS)" ./scripts/deploy_all.sh

setup-and-deploy: minikube-reset
	@echo "Apply/verify the required changes to /etc/hosts. Once done, press ENTER" && read L
	ORB_MIN=false ./scripts/deploy_all.sh

setup-and-deploy-orb-min: minikube-reset
	@echo "Apply/verify the required changes to /etc/hosts. Once done, press ENTER" && read L
	ORB_MIN=true ./scripts/deploy_all.sh

minikube-setup:
	cd scripts && ./minikube_setup.sh

minikube-reset:
	cd scripts && minikube delete ; ./minikube_setup.sh
