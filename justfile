set no-exit-message := true

export GENHOST_DOMAIN := "addeo.net"

chooser := "grep -v choose | fzf --tmux"

# Display this list of available commands
@list:
    just --justfile "{{ source_file() }}" --list

alias c := choose
# Open an interactive chooser of available commands
[no-exit-message]
@choose:
    just --justfile "{{ source_file() }}" --chooser "{{ chooser }}" --choose 2>/dev/null

alias e := edit
# Edit the justfile
@edit:
    $EDITOR "{{ justfile() }}"

@genhost *args:
    ./genhost {{ args }}

[working-directory("ansible")]
@inventory-graph inventory="prod":
    ansible-inventory -i {{ inventory }} --graph

[working-directory("ansible")]
@host-info host inventory="prod":
    ansible-inventory -i {{ inventory }} --host {{ if host =~ '\.' { host } else { host + ".addeo.net" }  }} | jq

[working-directory("ansible")]
@update-dns-records inventory="prod":
    ansible-playbook -i {{ inventory }} pfsense-server.yml --tags=dns-records

@download-startup-config:
  expect scripts/switch-ssh-exec.expect "copy startup-config tftp 10.1.51.154 startup.config"

@download-running-config:
  expect scripts/switch-ssh-exec.expect "copy running-config tftp 10.1.51.154 running.config"

[working-directory("ansible")]
_generate-switch-config file:
  #!/usr/bin/env bash
  ansible -i prod hamlet.addeo.net -e '@host_vars/hamlet.addeo.net.yml' -m debug -a 'var=brocade_startup_config' \
    | cut -d\> -f 2 \
    | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' \
    | jq -Mr '.brocade_startup_config' \
    > /private/tftpboot/{{ file }}

@upload-startup-config: (_generate-switch-config "startup.config")
  expect scripts/switch-ssh-exec.expect "copy tftp startup-config 10.1.51.154 startup.config"

@upload-running-config: (_generate-switch-config "running.config")
  expect scripts/switch-ssh-exec.expect "copy tftp running-config 10.1.51.154 running.config"
