# [WALLET](https://github.com/trustbloc/edge-agent) k8s deployment #


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
	- `myagent.DOMAIN`
	- `myagent-support.DOMAIN`
	- `router.DOMAIN`
	- `router-ws.DOMAIN`
	- `router-api.DOMAIN`
* Will deploy Sandbox WALLET with [HUB-ROUTER](https://github.com/trustbloc/hub-router), pointing to an already provisioned MySQL specified with `ARIESD_DATABASE_URL`, `HUB_ROUTER_DSN_PERSISTENT`, and `HUB_ROUTER_DSN_TRANSIENT`
	- `make deploy ARIESD_DATABASE_URL=user:pass@@tcp(address:3306)/`
* if running `podman` pass `CONTAINER_CMD=podman` as option to make
* Running with none self-signed certificates: place certs into kustomize/wallet/overlays/sandbox/certs, then run with: `make setup-no-certs`.
>files:
	- ca.crt
	- tls.crt
	- tls.key
