# Homelab Infrastructure


## Storage Server Provisioning
Storage servers are provisioned with an encrypted ZFS root on Debian 11. This
setup is based on [this guide][]. In order to provision a storage server first
boot to the live cd, and perform the following manual steps to prepare the
environment:

1. Run through the setup utility, and close out of the Getting Started help
   page.
2. Go to Settings (Drop down in top right corner > Settings) > Power and
   disable Automatic Suspend so that the server doesn't suspend/shut down
   during provisioning.
3. Go to the Networking Settings and configure the server with a static IP so
   that Ansible can reboot and continue running commands. Make sure to set the
   DNS server. Cycle the wired connection in the GUI to switch from DHCP to
   static.
3. Open a terminal.

```bash
$ gsettings set org.gnome.desktop.media-handling automount false
$ sudo passwd root # Set to 'live'
$ sudo sed -i 's/bullseye main$/bullseye main contrib/g' /etc/apt/sources.list
$ sudo apt update
$ sudo apt install --yes openssh-server
$ sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
$ sudo systemctl restart openssh-server
```

Now, using the static ip you can ssh into the server using the credentials
`root:live`.

### Determine which disks will be used and their identifiers
Next, we need to determine which disks will be used for boot and root and put
their identifiers into the respective servers `host_vars` file. We can use
`fdisk` and `ls -l /dev/disk/by-id/*` to do. We also need to define the pool
type, which can be: `single`, `mirror`, `raidz` ,`raidz2`, or `raidz3`. If
using `raidzX`, ensure you have the correct number of disks.

```yaml
zpool_type: mirror
zpool_disk_identifiers:
  - scsi-0QEMU_QEMU_HARDDISK_drive-scsi0
  - scsi-0QEMU_QEMU_HARDDISK_drive-scsi1
```

After you've determined which disks you'll be using, you must manually zap the
partition tables:

```bash
sgdisk --zap-all /dev/disk/by-id/<each disk identifier>
sgdisk --zap-all /dev/disk/by-id/<each disk identifier>
```

Finally, run through each playbook and you'll have a provisioned debian server
with an encrypted zfs root.

```bash
$ ansible-playbook -i dev debian-bootstrap-enc-zfs-root-part1.yml -e 'ansible_user=root ansible_ssh_pass=live' --ssh-common-args='-o userknownhostsfile=/dev/null'
$ ansible-playbook -i dev debian-bootstrap-enc-zfs-root-part2.yml -e 'ansible_user=root ansible_ssh_pass=live' --ssh-common-args='-o userknownhostsfile=/dev/null'
$ ansible-playbook -i dev debian-bootstrap-enc-zfs-root-part3.yml -e 'ansible_user=root ansible_ssh_pass=live' --ssh-common-args='-o userknownhostsfile=/dev/null'
```

[this guide]: https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/Debian%20Buster%20Root%20on%20ZFS.html#step-8-full-software-installation
