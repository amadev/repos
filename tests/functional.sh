#!/usr/bin/env bash

set -o errexit

echo
echo "Testing functional.sh"
echo "Use: REPOS_DEBUG=-vv bash -x tests/functional.sh for detailed output"

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"

function cleanup() {
    rm -rf /tmp/repos-test/
    mkdir -p /tmp/repos-test/orig/{r1,r2,r3}
}

function init_repos() {
    cd /tmp/repos-test/orig/r1
    echo master-r1-content > master-r1
    git init -q
    git add -A
    git commit -m "Auto-commit master-r1" -q
    git checkout -b b1 -q
    touch b1-r1
    git add -A
    git commit -m "Auto-commit b1-r1" -q

    cd /tmp/repos-test/orig/r2
    echo master-r2-content > master-r2
    git init -q
    git add -A
    git commit -m "Auto-commit master-r2" -q
    git checkout -b b1 -q
    touch b1-r2
    git add -A
    git commit -m "Auto-commit b1-r2" -q

    cd /tmp/repos-test/orig/r3
    touch master-r3
    git init -q
    git add -A
    git commit -m "Auto-commit master-r3" -q
    git checkout -b b1 -q
    touch b1-r3
    git add -A
    git commit -m "Auto-commit b1-r3" -q
}

function test_basic_opepations_with_initial_config() {
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
      --path /tmp/repos-test/r3 -t auto-commit --headers abc:def --name super-r3 $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos pull $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos pull $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos list $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos search master-r2-content $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos sync $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config.yaml $__DIR__/../repos add-group my-group --parent root $REPOS_DEBUG
}

function test_empty_db()  {
cat << 'EOF' > /tmp/repos-test/config1.yaml
db: /tmp/repos-test/db1.yaml
groups: /tmp/repos-test/groups1/
search_command: grep -HRin
repos_default_directory: $HOME/src/
log: /var/log/repos/repos.log
EOF
    REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos list $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos add-group g1 $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos add-group g2 $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos add-group g1.1 --parent g1 $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos add-group g2.1 --parent g2 $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos add /tmp/repos-test/orig/r3 -g g2.1 $REPOS_DEBUG
    REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos add /tmp/repos-test/orig/r3 | grep "already exists"
    REPOS_CONFIG=/tmp/repos-test/config1.yaml $__DIR__/../repos list $REPOS_DEBUG
}

cleanup
init_repos
test_basic_opepations_with_initial_config
test_empty_db
echo "ok"
