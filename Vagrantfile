require_relative "lib/vagrant/plugins"

servers = [
  {
    hostname: "testbed.addeo.net",
    # @TODO update vagrant box to bookworm
    box: "bullseye64-zfsroot",
    cpu: 2,
    memory: 2048,
    ip: "192.168.33.65",
    ssh_port: 54321,
    additional_disks: [
      {name: "test1", size: "1GB"},
      {name: "test2", size: "1GB"},
      {name: "test3", size: "1GB"}
    ]
  }
]

ensure_plugins([
  {"name" => "vagrant-vbguest"},
  {"name" => "vagrant-hostsupdater"}
])

Vagrant.configure("2") do |config|
  servers.each do |settings|
    config.vm.define settings[:hostname] do |server|
      server.ssh.forward_agent = true
      server.ssh.insert_key = true

      server.vm.box = settings[:box]
      server.vm.hostname = settings[:hostname]
      server.vm.network :private_network, ip: settings[:ip]
      server.vm.network :forwarded_port, id: "ssh", host: settings[:ssh_port], guest: 22
      server.vm.network :forwarded_port, id: "proxmox", host: 8006, guest: 8006

      if not settings[:additional_disks].nil?
        settings[:additional_disks].each do |disk|
          server.vm.disk :disk, name: disk[:name], size: disk[:size]
        end
      end

      server.vm.provider :virtualbox do |vb|
        vb.name = settings[:hostname]
        vb.cpus = settings[:cpu]
        vb.memory = settings[:memory]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end
    end
  end
end
