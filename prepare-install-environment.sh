#!/usr/bin/env bash

main() {
  sudo usermod --password $(openssl passwd -1 'live') root
  # @TODO this also needs to remove the live cd line as it causes problems for some raeson
  sudo sed -i 's/bookworm main non-free-firmware$/bookworm main contrib non-free-firmware/g' /etc/apt/sources.list
  sudo apt update
  sudo apt install --yes openssh-server gdisk
  sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
  sudo systemctl restart ssh
}

main "$@"
