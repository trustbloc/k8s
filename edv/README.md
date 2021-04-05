# [EDV](https://github.com/trustbloc/edv) k8s deployment #


## pre-requisits
* [Minikube](https://minikube.sigs.k8s.io/docs/start/) with ingress addon.
* Docker config file with github token under `kustomize/edv/base/registry/.dockerconfigjson`
* (Optional: Gets installed by make) [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/).

Example:

		{
			"auths": {
				"docker.pkg.github.com": {
					"auth": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
				},
				"ghcr.io": {
					"auth": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
				}
			},
			"HttpHeaders": {
				"User-Agent": "Docker-Client/19.03.13 (linux)"
			}
		}

## Quick Run
* `make all`
* `make deploy`

## Cleanup
* `make undeploy`
* `make clean`

## options and features
* By default dns domain is `trustboc.dev`. To run with different domain (See next), run with: `make DOMAIN=ali.trustbloc.dev`
* Will create an Ingress for external access. When running with unregistered dns domains, create records (/etc/hosts) for:
	- `edv.DOMAIN`
	- `edv-oathkeeper-proxy.DOMAIN`
*  CouchDB single instance.
* if running `podman` pass `CONTAINER_CMD=podman` as option to make
* Will deploy Sandbox EDV with [oathkeeper](https://github.com/ory/oathkeeper) pointing to an existing CouchDB:
	- `make deploy-sandbox COUCHDB_URL=user:pass@couchdb-address:port`
* Running with none self-signed certificates: place certs into kustomize/edv/overlays/sandbox/certs, then run with: `make setup-no-certs`.
>files:
	- ca.crt
	- tls.crt
	- tls.key
