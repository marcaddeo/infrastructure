# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add additional nodes to k8s staging environment
- Add nfs share to kilo for use on staging k8s cluster
- Add ability to apply custom Talos machine config to control plane nodes only
- Add nfs-subdir-external-provisioner to k8s cluster to allow NFS PVCs
- Add an oauth2-proxy ResourceSet to allow templating oauth2-proxy into
  namespaces that require it
- Add capacitor, a UI for FluxCD
- Add external-dns to synchronize ingress hosts to Cloudflare DNS
- Add a proxmox EndpointSlice to Kubernetes that forwards to all Proxmox nodes
  in the cluster
- Add OIDC login to Proxmox
- Add garage-operator to enable S3-style object storage for the k8s cluster
- Add cloudnativepg-operator for easy deployments of postgres clusters in k8s

### Changed

- Update Talos node provisioning to include SAN vmbr1
- Update the Talos machine configurations to ensure nodes can access the SAN
  and nodes/etcd are using the correct subnet
- Configure SMTP and Email settings in pocket-id
- Configure additional network interfaces on alfred
- Update the onepassword-operator to poll more frequently for updates
- Migrate pocket-id to pocket-id-operator and into the infrastructure configs
  to allow easier configuration and management of pocket-id

### Fixed

- Fix annotations on the vmpool-ephemeral StorageClass so it can be properly
  selected as the default

### Removed

- Remove lgtm-stack application due to it no longer being maintained and never
  getting completely configured within the cluster

## [0.1.0] - 2025-05-18

### Added

- Initial tagged release

[Unreleased]: https://github.com/marcaddeo/infrastructure/compare/0.1.0...HEAD
[0.1.0]: https://github.com/marcaddeo/infrastructure/releases/tag/0.1.0
