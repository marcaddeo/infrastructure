require_relative "lib/vagrant/plugins"

servers = [
  {
    hostname: "sql01.tst.grow.marc.cx",
    box: "geerlingguy/debian9",
    cpu: 1,
    memory: 1024,
    ip: "192.168.33.100"
  },
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

      server.vm.provider :virtualbox do |vb|
        vb.name = settings[:hostname]
        vb.cpus = settings[:cpu]
        vb.memory = settings[:memory]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      end

      server.vm.provision "ansible" do |ansible|
        ansible.playbook = "provisioning/server.yml"
        ansible.limit = settings[:hostname]
        ansible.inventory_path = "provisioning/inventories/tst"
      end
    end
  end
end
