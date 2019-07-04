#!/usr/bin/env bash

set -o pipefail
set -o errexit

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

mkdir -p "$HOME/.repos/"

if [ ! -f "$HOME/.repos/config.yaml" ]; then
cat << 'EOF' > ~/.repos/config.yaml
db: $HOME/.repos/db.yaml
groups: $HOME/.repos/groups/
search_command: grep -HRin
repos_default_directory: $HOME/src/
log: /var/log/repos/repos.log
EOF
fi

if [ ! -f "$HOME/.repos/db.yaml" ]; then
cat << 'EOF' > ~/.repos/db.yaml
repos: []
groups:
  - name: root
EOF
fi

u=$(logname)
chown -R $u:$u "$HOME/.repos/"

wget -q https://github.com/candid82/joker/releases/download/v0.12.4/joker-0.12.4-linux-amd64.zip -O /tmp/joker.zip
cd /tmp
unzip joker.zip
mv joker /usr/local/bin/joker

cat << EOF > /usr/local/bin/repos
#!/usr/bin/env bash

$__DIR__/repos "\$@"
EOF
chmod 755 /usr/local/bin/repos
