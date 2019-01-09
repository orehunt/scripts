#!/bin/bash

. /etc/profile.d/func.sh || { echo missing required functions file /etc/profile.d/func.sh; exit 1; }
cd /opt/ci/config

interval=${MONITORED_INTERVAL:-3600}
repo=${MONITORED_REPO}
[ -z "$repo" ] && { echo missing \$MONITORED_REPO; exit 1; }
ref=${HOOK_REF}
[ -z "$ref" ] && { echo missing \$HOOK_REF; exit 1; }
token=${HOOK_TOKEN}
[ -z "$token" ] && { echo missing \$HOOK_TOKEN; exit 1; }
url=${HOOK_URL}
[ -z "$url" ] && { echo missing \$HOOK_URL; exit 1; }

lv=$(</var/log/repomonitor_lv.log)
while :; do
    nlv=$(git_versions $repo c | sort -bt. -k1nr -k2nr -k3r -k4r -k5r | head -1)
    if [ "$nlv" != "$lv" ]; then
        wget -qO- --post-data="token=${HOOK_TOKEN}&ref=""${HOOK_REF}" -i- <<< "${HOOK_URL}"
        lv=$nlv
        echo "$lv" > /var/log/repomonitor_lv.log
    fi
    sleep 3600
done
