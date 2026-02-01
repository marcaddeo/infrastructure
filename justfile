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
    expect scripts/switch-ssh-exec.expect "copy startup-config tftp 10.1.51.31 startup.config"

[doc("Download the running-config from the switch")]
@download-running-config:
    expect scripts/switch-ssh-exec.expect "copy running-config tftp 10.1.51.31 running.config"

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
    expect scripts/switch-ssh-exec.expect "copy tftp startup-config 10.1.51.31 startup.config"

[doc("Upload the switch configuration to the switches running-config")]
@upload-running-config: (_generate-switch-config "running.config")
    expect scripts/switch-ssh-exec.expect "copy tftp running-config 10.1.51.31 running.config"

@op-base64-inject file:
    perl -ne 's/{{{{ base64-(op.*) }}/`echo "$1" | op inject | base64 | tr "\/+" "_-" | tr -d "=" | tr -d "\n"`/e;print' {{ file }}

talos-up env="staging":
    tofu -chdir=tofu/{{ env }} apply -target=module.talos
    tofu -chdir=tofu/{{ env }} output -raw kube_config > tmp-kube-config.yaml
    KUBECONFIG="./tmp-kube-config.yaml:~/.kube/config" \
        kubectl config view --flatten > ~/.kube/config-new && mv ~/.kube/config{-new,}
    rm tmp-kube-config.yaml

talos-down env="staging":
    tofu -chdir=tofu/{{ env }} destroy -target=module.talos

k8s-bootstrap env="staging":
    tofu -chdir=tofu/{{ env }} apply -target=module.proxmox_pvc_volumes
    kubectl config set-context admin@{{ env }}.talos.addeo.net
    just op-base64-inject k8s/infrastructure/secrets.yaml \
        | op inject \
        | kubectl apply -f -
    helm install --namespace kube-system \
        --set "existingConfigSecret=proxmox-cluster" \
        proxmox-cloud-controller-manager \
        oci://ghcr.io/sergelogvinov/charts/proxmox-cloud-controller-manager
    helm install --namespace flux-system \
        --create-namespace \
        flux-operator \
        oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator
    kubectl apply -f k8s/clusters/{{ env }}/flux.yaml

k8s-rebuild env="staging": (talos-down env) (talos-up env) (k8s-bootstrap env)

@rancher-token env="staging":
    curl 'https://rancher.{{ env }}.addeo.net/v3-public/localProviders/local?action=login' \
        --silent \
        --insecure \
        -H 'accept: application/json' \
        -H 'content-type: application/json' \
        --data-raw '{"description":"Tofu Token","responseType":"token","username":"admin","password":"'$(op read "op://Private/2pxh6dasbem4xfv42orccrwaiu/password")'"}' \
    | jq -rM '.token'

pvc-volumes env="staging" encode="true":
    #!/usr/bin/env bash
    {
        kubectl kustomize k8s/apps/{{ env }};
        flux build kustomization infra-configs --path k8s/clusters/{{ env }} --recursive --local-sources=GitRepository/flux-system/flux-system={{ justfile_directory() }};
    } \
        | yq -o json ea '[.] | .[] | select(.kind == "PersistentVolume" and .spec.storageClassName == "vmpool-persistent")' \
        | jq -rMs 'reduce .[] as $item ({}; . + {
            ($item.spec.csi.volumeHandle | split("/") | .[3] | sub("vm-\\d+-"; "")): {
                node: ($item.spec.csi.volumeHandle | split("/") | .[1]),
                size: ($item.spec.capacity.storage | sub("(?<unit>G|M)i"; "\(.unit)"))
            }
            })' \
    {{ if encode == "true" { "| base64 | tr -d '\n' | jq -R '{base64: .}'" } else { "" } }}
