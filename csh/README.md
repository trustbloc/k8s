# [confidential-storage-hub](https://github.com/trustbloc/edge-service) k8s deployment #


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
* By default dns domain is `local.trustboc.dev`. To run with different domain (See next), run with: `make DOMAIN=ali.trustbloc.dev`
* Will create an Ingress for external access. When running with unregistered dns domains, create records (/etc/hosts) for:
	- `csh.DOMAIN`
* Will deploy Sandbox CSH, pointing to an already provisioned COUCHDB specified with `COUCHDB_DSN`
	- `make deploy COUCHDB_DSN=couchdb://cdbadmin:secret@couchdb:5984`
* if running `podman` pass `CONTAINER_CMD=podman` as option to make
* Running with none self-signed certificates: place certs into kustomize/csh/overlays/sandbox/certs, then run with: `make setup-no-certs`.
>files:
	- ca.crt
	- tls.crt
	- tls.key

## Known issues
* comparator sandbox overlays will fail if csh.DOMAIN (hubstore)
is not reachable
