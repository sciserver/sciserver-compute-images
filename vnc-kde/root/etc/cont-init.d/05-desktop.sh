#!/command/with-contenv bash

set -eu
set -o pipefail

s6-setuidgid idies mkdir -p "$HOME/Desktop"
mkdir -p /misc/desktop
mv /misc/desktop/* "$HOME/Desktop"
