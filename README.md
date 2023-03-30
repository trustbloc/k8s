# TrustBloc Deployment

The repo contains the scripts to deploy the core TrustBloc components.

## Prerequisites
- docker (running) [For Apple Silicon-based Macs, must be v3.6.0 or higher]
- [minikube](https://minikube.sigs.k8s.io/docs/start/) [[v1.28.0](#minikube-installation) or higher]
- [kubectl](https://kubernetes.io/docs/tasks/tools/)  [v1.25.8 or higher]
- GNU bash [v5 or higher] (for macOS, refer to [macos setup](#macos-additional-prerequisites))
- GNU make
- GNU sed

### MacOS additional prerequisites
- Install GNU sed and base64 utils: `brew install gnu-sed coreutils bash jq`
- Create directory with symlinks to the used GNU tools
  ```
  # mkdir ~/gnu && cd ~/gnu && ln -fs $( which gsed ) sed && ln -fs $( which gbase64 ) base64
  ```
- Always prepend the directory with GNU tools to the PATH when using this repo or add this to the bash profile, e.g.:
  ```
  # PATH=~/gnu:$PATH
  ```

#### For Apple Silicon (arm64) Macs
- The brew [docker-mac-net-connect](https://github.com/chipmk/docker-mac-net-connect) service installed:
  ```
  brew install chipmk/tap/docker-mac-net-connect
  ```
  Important: See the [Running](#running) section below to see how to correctly run the service.

#### For Intel (x86-64) Macs

- [HyperKit](https://minikube.sigs.k8s.io/docs/drivers/hyperkit/) installed

### Minikube installation

#### macOS - Apple Silicon (arm64)
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64
sudo install minikube-darwin-arm64 /usr/local/bin/minikube
```

#### macOS - Intel (x86-64)
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
sudo install minikube-darwin-amd64 /usr/local/bin/minikube
```

#### linux (x86-64)
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

## Running

### Important Extra Step for Apple Silicon Macs
If using an Apple Silicon (arm64)-based Mac, before attempting to start up Sandbox, you will need to start the `docker-mac-net-connect` brew service with root permissions to ensure that host-to-VM communication works:

```
sudo brew services start chipmk/tap/docker-mac-net-connect
```

Note that the service will not be able to connect to Docker without root permissions.

### Some Common Commands

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

## Workaround for connection issues when using a VPN on macOS

Certain VPNs (on the host machine) have known issues with port conflicts when using the Hyperkit driver. The Hyperkit
driver is used when running on an x86-64 machine.

If disabling the VPN is not possible, one workaround is to use the `docker` driver along with the `docker-mac-net-connect` brew service.

To do this:
1. Install the brew [docker-mac-net-connect](https://github.com/chipmk/docker-mac-net-connect) service: `brew install chipmk/tap/docker-mac-net-connect`.
2. Start the service: `sudo brew services start chipmk/tap/docker-mac-net-connect`. Note: must be started with root permissions.
3. Change the driver to `docker` in the `minikube_setup.sh` script.

## Contributing
Thank you for your interest in contributing. Please see our [community contribution guidelines](https://github.com/trustbloc/community/blob/main/CONTRIBUTING.md) for more information.

## License
Apache License, Version 2.0 (Apache-2.0). See the [LICENSE](LICENSE) file.
