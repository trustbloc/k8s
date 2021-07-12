# orb k8s deployment #


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
* When running with unregistered dns domains, create records (/etc/hosts) for:
	- orb.DOMAIN
* When running `podman` pass `CONTAINER_CMD=podman` as option to make.
* Running with none self-signed certificates: place certs into kustomize/orb/overlays/sandbox/certs, then run with: `make setup-no-certs`
>files:
	- ca.crt
	- tls.crt
	- tls.key
