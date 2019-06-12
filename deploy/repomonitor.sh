#!/bin/bash

. /etc/profile.d/func.sh || { echo missing required functions file /etc/profile.d/func.sh; exit 1; }

export GIT_PAGER=true
interval=${MONITORED_INTERVAL:-3600}
repos=${MONITORED_REPOS}
[ -z "$repos" ] && { echo missing \$MONITORED_REPOS; exit 1; }
ref=${HOOK_REF}
[ -z "$ref" ] && { echo missing \$HOOK_REF; exit 1; }
token=${HOOK_TOKEN}
[ -z "$token" ] && { echo missing \$HOOK_TOKEN; exit 1; }
url=${HOOK_URL}
[ -z "$url" ] && { echo missing \$HOOK_URL; exit 1; }

function check_version(){
    cd /opt/ci/config
    nlv=$(git_versions "$1" c | sort -V | tail -1)
    cd -
}

function trigger_build(){
    case "$1" in
        gl)
            wget -qO- --post-data="token=${HOOK_TOKEN}&ref=""${HOOK_REF}" -i- <<< "${HOOK_URL}"
            ;;
        gh)
            cd "${BUILD_REPO}"
            git fetch --all
            git reset --hard
            git pull --force
            git tag "${nlv}-${2}"
            git push origin "${nlv}-${2}"
            cd -
            ;;
    esac
}

function check_commit(){
    cd /opt/ci/config
    nlv=$(git ls-remote "$1" HEAD | awk '{print $1}')
    cd -
}

declare -A reposv
mkdir -p /var/log/repomonitor
loop_sleep=3600
repos_count=$(($(echo "${repos%,}" | tr -cd , | wc -m)+1))
sleep_ival=$((loop_sleep/repos_count))
while :; do
    for r in $(sed 's/,/ /' <<< "$repos"); do
        repo=${r%:*}
        method=${r//*:}
        reposv[$repo]=$(<"/var/log/repomonitor/$repo.log")
        case "$method" in
            v) check_version "$repo"
            ;;
            c) check_commit "$repo"
            ;;
        esac
        if [ "$nlv" != "${reposv[$repo]}" -o -z "${reposv[$repo]}" ]; then
            trigger_build "${CI:-gh}" "$repo"
            reposv[$repo]=$nlv
            echo "$nlv" > "/var/log/repomonitor/$repo.log"
        fi
        sleep $sleep_ival
    done
done
