# [VCS](https://github.com/trustbloc/vcs) k8s deployment #


## pre-requisits
* [Minikube](https://minikube.sigs.k8s.io/docs/start/) with ingress addon.
* (Optional: Gets installed by make) [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/).

## Quick Run
* `make all`
* `make deploy`

## Cleanup
* `make undeploy`
* `make clean`

## options and features
* By default dns domain is `local.trustboc.dev`. To run with different domain (See next), run with: `make DOMAIN=ali.trustbloc.dev`
* Will create an Ingress for external access. When running with unregistered dns domains, create records (/etc/hosts) for:
	- `vcs.DOMAIN`
*  MongoDB single instance.
* if running `podman` pass `CONTAINER_CMD=podman` as option to make
* Will deploy Sandbox VCS with [oathkeeper](https://github.com/ory/oathkeeper) pointing to an existing MongoDB:
	- `make deploy-sandbox MONGODB_URL=mongodb://user:pass@mongodb-address:27017`
* Running with none self-signed certificates: place certs into kustomize/vcs/overlays/sandbox/certs, then run with: `make setup-no-certs`.
>files:
	- ca.crt
	- tls.crt
	- tls.key
