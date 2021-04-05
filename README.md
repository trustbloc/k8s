# TrustBloc Deployment

The repo contains the scripts to deploy the core TrustBloc components.

## Prerequisites
- docker (running)
- [minikube](https://minikube.sigs.k8s.io/docs/start/) [minimum version: v1.18]
- [kubectl](https://kubernetes.io/docs/tasks/tools/)  [minimum version: v1.20]
- GNU bash [minimum version: v5]
- GNU make
- GNU sed

### MacOS additional prerequisites
- HyperKit installed
- Install GNU sed and base64 utils: `brew install gnu-sed coreutils bash`
- Create directory with symlinks to the used GNU tools
  ```
  # mkdir ~/gnu && cd ~/gnu && ln -fs $( which gsed ) sed && ln -fs $( which gbase64 ) base64
  ```
- Always prepend the directory with GNU tools to the PATH when using this repo, e.g.:
  ```
  # PATH=~/gnu:$PATH
  # make setup-and-deploy
  ```

## Running

Re-create any existing minikube cluster and deploy all trustbloc services into the newly created cluster:

`make setup-and-deploy`

Deploy all components to the existing kubernetes cluster:

`make`

Deploy specific components to the existing kubernetes cluster:

`make deploy-components COMPONENTS="component1 component2 component3"`

Minikube cluster setup:

`make minikube-setup`

Minikube cluster re-create:

`make minikube-reset`

## Kubernetes Dashboard

To access the dashboard run `kubectl port-forward svc/kubernetes-dashboard -n kubernetes-dashboard 8888:80` and browse to the port-forwarded URL: http://localhost:8888

## Contributing
Thank you for your interest in contributing. Please see our [community contribution guidelines](https://github.com/trustbloc/community/blob/main/CONTRIBUTING.md) for more information.

## License
Apache License, Version 2.0 (Apache-2.0). See the [LICENSE](LICENSE) file.
