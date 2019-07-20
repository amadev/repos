#!/usr/bin/env bash

set -o pipefail
set -o errexit

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"

rm -rf /tmp/repos-test/
mkdir -p /tmp/repos-test/orig/{r1,r2,r3}

cd /tmp/repos-test/orig/r1
echo master-r1-content > master-r1
git init
git add -A
git commit -m "Auto-commit master-r1"
git checkout -b b1
touch b1-r1
git add -A
git commit -m "Auto-commit b1-r1"

cd /tmp/repos-test/orig/r2
echo master-r2-content > master-r2
git init
git add -A
git commit -m "Auto-commit master-r2"
git checkout -b b1
touch b1-r2
git add -A
git commit -m "Auto-commit b1-r2"

cd /tmp/repos-test/orig/r3
touch master-r3
git init
git add -A
git commit -m "Auto-commit master-r3"
git checkout -b b1
touch b1-r3
git add -A
git commit -m "Auto-commit b1-r3"

cat << 'EOF' > /tmp/repos-test/config.yaml
db: /tmp/repos-test/db.yaml
groups: /tmp/repos-test/groups/
search_command: grep -HRin
repos_default_directory: $HOME/src/
log: /var/log/repos/repos.log
EOF

cat << EOF > /tmp/repos-test/db.yaml
repos:
  - name: r1
    path: /tmp/repos-test/r1
    tags: []
    group: openstack
    remotes:
      - name: origin
        url: /tmp/repos-test/orig/r1
      - name: r2
        url: /tmp/repos-test/orig/r2
    branches:
      - name: master
        remote: origin
        refspec: master
      - name: b1
        remote: origin
        refspec: b1
      - name: r2-master
        remote: r2
        refspec: master
      - name: r2-b1
        remote: r2
        refspec: b1

  - name: r2
    path: /tmp/repos-test/r2
    tags:
      - shallow
    group: openstack
    remotes:
      - name: origin
        url: /tmp/repos-test/orig/r2
    branches:
      - name: master
        remote: origin
        refspec: master
groups:
  - name: root
  - name: openstack
    parent: root
EOF

REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos add /tmp/repos-test/orig/r3 \
  --path /tmp/repos-test/r3 -t auto-commit --headers abc:def -vv --name super-r3

REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos pull -vv

REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos pull -vv

REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos list -vv

REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos search master-r2-content -vv

REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos sync -vv

REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos add-group my-group --parent root -vv


# test empty db

cat << 'EOF' > /tmp/repos-test/config1.yaml
db: /tmp/repos-test/db1.yaml
groups: /tmp/repos-test/groups1/
search_command: grep -HRin
repos_default_directory: $HOME/src/
log: /var/log/repos/repos.log
EOF

REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos add-group g1 -vv

REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos add-group g2 -vv

REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos add-group g1.1 --parent g1 -vv

REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos add-group g2.1 --parent g2 -vv

REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos add /tmp/repos-test/orig/r3 -vv
