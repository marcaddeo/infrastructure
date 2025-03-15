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

@inventory-graph inventory="prod":
    ansible-inventory -i ansible/{{ inventory }} --graph

@host-info host inventory="prod":
    ansible-inventory -i ansible/{{ inventory }} --host {{ if host =~ '\.' { host } else { host + ".addeo.net" }  }} | jq
