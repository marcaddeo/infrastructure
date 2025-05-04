set no-exit-message := true

export GENHOST_DOMAIN := "addeo.net"

chooser := "grep -v choose | fzf --tmux"

[doc("Display this list of available commands")]
@list:
    just --justfile "{{ source_file() }}" --list

alias c := choose
[doc("Open an interactive chooser of available commands")]
@choose:
    just --justfile "{{ source_file() }}" --chooser "{{ chooser }}" --choose 2>/dev/null

alias e := edit
[doc("Edit the justfile")]
@edit:
    $EDITOR "{{ justfile() }}"

[doc("Generate a hostname using a wordlist")]
@genhost *args:
    ./scripts/genhost {{ args }}

[working-directory("ansible")]
[doc("Show a graph of the ansible inventory")]
@inventory-graph inventory="prod":
    ansible-inventory -i {{ inventory }} --graph

[working-directory("ansible")]
[doc("Show host vars for a host in the ansible inventory")]
host-info host inventory="prod":
    #!/usr/bin/env bash
    host="{{ if host =~ '\.' { host } else { host + ".addeo.net" }  }}"
    ansible -i {{ inventory }} "$host" -e "@host_vars/$host.yml" -m debug -a "var=hostvars['$host']" \
        | cut -d\> -f 2 \
        | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' \
        | jq '.[]'

[working-directory("ansible")]
[doc("Show device info vars for a host in the ansible inventory")]
@device-info host inventory="prod":
    just --justfile "{{ source_file() }}" host-info {{ host }} {{ inventory }} | jq '. | with_entries(select(.key | startswith("device_")))'

[working-directory("ansible")]
[doc("Update DNS records on DNS servers")]
@update-dns-records inventory="prod":
    ansible-playbook -i {{ inventory }} pfsense-server.yml --tags=dns-records

[working-directory("ansible")]
[doc("Update DHCP static mappings on pfSense")]
@update-dhcp-static-mappings inventory="prod":
    ansible-playbook -i {{ inventory }} pfsense-server.yml --tags=dhcp-static-mappings

[doc("Download the startup-config from the switch")]
@download-startup-config:
    expect scripts/switch-ssh-exec.expect "copy startup-config tftp 10.1.51.154 startup.config"

[doc("Download the running-config from the switch")]
@download-running-config:
    expect scripts/switch-ssh-exec.expect "copy running-config tftp 10.1.51.154 running.config"

[working-directory("ansible")]
[doc("Generate a configuration file for the switch")]
_generate-switch-config file:
    #!/usr/bin/env bash
    ansible -i prod hamlet.addeo.net -e '@host_vars/hamlet.addeo.net.yml' -m debug -a 'var=brocade_startup_config' \
        | cut -d\> -f 2 \
        | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' \
        | jq -Mr '.brocade_startup_config' \
        > /private/tftpboot/{{ file }}

[doc("Upload the switch configuration to the switches startup-config")]
@upload-startup-config: (_generate-switch-config "startup.config")
    expect scripts/switch-ssh-exec.expect "copy tftp startup-config 10.1.51.154 startup.config"

[doc("Upload the switch configuration to the switches running-config")]
@upload-running-config: (_generate-switch-config "running.config")
    expect scripts/switch-ssh-exec.expect "copy tftp running-config 10.1.51.154 running.config"

[working-directory("tofu")]
k8s-rebuild:
    tofu destroy
    tofu apply
    tofu output -raw kubeconfig > kubeconfig.yaml
    KUBECONFIG=./kubeconfig.yaml:~/.kube/config kubectl config view --flatten > ~/.kube/config-new && mv ~/.kube/config{-new,}
    rm kubeconfig.yaml
    git rm ../k8s/clusters/production/flux-system/* || true
    git commit -m "Remove old flux" || true
    git push
    GITHUB_TOKEN="$(gh auth token)" flux bootstrap github --token-auth --owner=marcaddeo --repository=infrastructure --branch=master --path=../k8s/clusters/production --personal
    git pull --rebase
