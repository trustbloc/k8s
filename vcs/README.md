# [VCS](https://github.com/trustbloc/edge-service) k8s deployment #


## pre-requisits
* [Minikube](https://minikube.sigs.k8s.io/docs/start/) with ingress addon.
* GNU sed
* (Optional: Gets installed by make) [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/).

## Quick Run
* `make all`
* `make deploy-sandbox`

## Cleanup
* `make undeploy-sandbox`
* `make clean`

## options and features
* By default dns domain is `trustboc.dev`. To run with different domain (See next), run with: `make DOMAIN=ali.trustbloc.dev`
* By default Bloc domain is `testnet.trustboc.dev`. To run with different domain (See next), run with: `make BLOC_DOMAIN=testnet.ali.trustbloc.dev`
* Will create an Ingress for external access. When running with unregistered dns domains, create records (/etc/hosts) for:
	- `issuer-vcs.DOMAIN`
	- `rp-vcs.DOMAIN`
	- `holder-vcs.DOMAIN`
	- `governance-vcs.DOMAIN`
* Will deploy Sandbox VCS, pointing to an already provisioned COUCHDB specified with `COUCHDB_URL`
	- `make deploy COUCHDB_URL=cdbadmin:secret@couchdb:5984`
* if running `podman` pass `CONTAINER_CMD=podman` as option to make
* Running with none self-signed certificates: place certs into kustomize/vcs/overlays/sandbox/certs, then run with: `make setup-no-certs`.
>files:
	- ca.crt
	- tls.crt
	- tls.key
