#!/usr/bin/env bash

set -o pipefail
set -o errexit

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

# mkdir -p ~/.repos/
# cat << 'EOF' > ~/.repos/db.yaml
# repos: []
# groups: []
# EOF

cat << EOF > /usr/local/bin/repos
#!/usr/bin/env bash

$__DIR__/repos \$@
EOF
chmod 755 /usr/local/bin/repos
