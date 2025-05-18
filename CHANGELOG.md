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

### Changed

- Update Talos node provisioning to include SAN vmbr1
- Update the Talos machine configurations to ensure nodes can access the SAN
  and nodes/etcd are using the correct subnet

## [0.1.0] - 2025-05-18

### Added

- Initial tagged release

[Unreleased]: https://github.com/marcaddeo/infrastructure/compare/0.1.0...HEAD
[0.1.0]: https://github.com/marcaddeo/infrastructure/releases/tag/0.1.0
