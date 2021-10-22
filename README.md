# TrustBloc Deployment

The repo contains the scripts to deploy the core TrustBloc components.

## Prerequisites
- docker (running)
- [minikube](https://minikube.sigs.k8s.io/docs/start/) [IMP: supported version: [v1.20](#minikube-installation)]
- [kubectl](https://kubernetes.io/docs/tasks/tools/)  [supported version: v1.20]
- GNU bash [minimum version: v5] (for macOS, refer [macos setup](#macos-additional-prerequisites))
- GNU make
- GNU sed

### MacOS additional prerequisites
- [HyperKit](https://minikube.sigs.k8s.io/docs/drivers/hyperkit/) installed
- Install GNU sed and base64 utils: `brew install gnu-sed coreutils bash`
- Create directory with symlinks to the used GNU tools
  ```
  # mkdir ~/gnu && cd ~/gnu && ln -fs $( which gsed ) sed && ln -fs $( which gbase64 ) base64
  ```
- Always prepend the directory with GNU tools to the PATH when using this repo or add this to the bash profile, e.g.:
  ```
  # PATH=~/gnu:$PATH
  ```

### Minikube installation

#### v.1.20.0
##### macOS
```
curl -LO https://github.com/kubernetes/minikube/releases/download/v1.20.0/minikube-darwin-amd64

sudo install minikube-darwin-amd64 /usr/local/bin/minikube
```

##### linux
```
curl -LO https://github.com/kubernetes/minikube/releases/download/v1.20.0/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube
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

Open the dashboard in a browser:

`minikube dashboard`

## Contributing
Thank you for your interest in contributing. Please see our [community contribution guidelines](https://github.com/trustbloc/community/blob/main/CONTRIBUTING.md) for more information.

## License
Apache License, Version 2.0 (Apache-2.0). See the [LICENSE](LICENSE) file.
