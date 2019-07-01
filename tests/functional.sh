#!/usr/bin/env bash

set -o pipefail
set -o errexit

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"

rm -rf /tmp/repos-test/
mkdir -p /tmp/repos-test/orig/{r1,r2,r3}

cd /tmp/repos-test/orig/r1
touch master-r1
git init
git add -A
git commit -m "Auto-commit master-r1"
git checkout -b b1
touch b1-r1
git add -A
git commit -m "Auto-commit b1-r1"

cd /tmp/repos-test/orig/r2
touch master-r2
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
    tags: []
    group: openstack
    remotes:
      - name: origin
        url: /tmp/repos-test/orig/r2
    branches:
      - name: master
        remote: origin
        refspec: master
      - name: b1
        remote: origin
        refspec: b1
EOF

REPOS_DB=/tmp/repos-test/db.yaml $__DIR__/../repos add /tmp/repos-test/orig/r3 --path /tmp/repos-test/r3 -vv

REPOS_DB=/tmp/repos-test/db.yaml $__DIR__/../repos pull -vv

REPOS_DB=/tmp/repos-test/db.yaml $__DIR__/../repos pull -vv
