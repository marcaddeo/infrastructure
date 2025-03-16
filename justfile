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
@dns-records inventory="prod":
    ansible-playbook -i {{ inventory }} pfsense-server.yml --tags=dns-records
