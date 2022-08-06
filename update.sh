#! /usr/bin/env bash

set -eu

update_node_pkgs() {
    dir="$1"
    pushd "$1"
    nix run nixpkgs#node2nix -- -16 -i node-packages.json
    popd

    return $?
}

nix flake update
update_node_pkgs home/dev/dlang/coc-dlang


