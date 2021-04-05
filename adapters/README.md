# [adapters](https://github.com/trustbloc/edge-adapter) k8s deployment #


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
* Will create an Ingress for external access. When running with unregistered dns domains, create records (/etc/hosts) for:
	- `adapter-issuer.DOMAIN`
	- `adapter-issuer-didcomm.DOMAIN`
	- `adapter-rp.DOMAIN`
	- `adapter-rp-didcomm.DOMAIN`
	- `adapter-hydra.DOMAIN`
	- `adapter-hydra-admin.DOMAIN`
* Will deploy Sandbox adapters with [Hydra](https://github.com/ory/hydra), pointing to an already provisioned MySQL specified with `HYDRA_MYSQL_DSN`, `ISSUER_ADAPTER_REST_DSN`, and `RP_ADAPTER_REST_DSN`:
	- `make deploy HYDRA_MYSQL_DSN=mysql://user:pass@@tcp(address:3306)`
* if running `podman` pass `CONTAINER_CMD=podman` as option to make
* Running with none self-signed certificates: place certs into kustomize/adapters/overlays/sandbox/certs, then run with: `make setup-no-certs`.
>files:
	- ca.crt
	- tls.crt
	- tls.key
## Known issues
* base is broken until this is resolved: https://github.com/trustbloc/edge-adapter/issues/323
* sidetree-mock/sidetree BLOC_DOMAIN needs to be reachable for issuer adapter to be initialized with profiles, therefore issuer-add-profiles job will always fail if otherwise
