{
    "algo": "${AL}",
    "aesni": ${AESNI},
    "pow-variant": "${AL_V:-1}",
    "threads": "${THREADS}",
    "multihash-factor": "${MHF}",
    "multihash-thread-mask" : "0x0",
    "background": false,
    "colors": false,
    "cpu-affinity": "${AFFINITY}",
    "cpu-priority": "2",
    "donate-level": 0,
    "log-file": null,
    "max-cpu-usage": 100,
    "print-time": 360,
    "retries": 5,
    "retry-pause": 5,
    "safe": false,
    "syslog": false,
    "pools": [
        {
            "url": "${TNL_LISTEN_ADDR1:-xnp1.service.cluster.consulate.ga}:${TNL_LISTEN_PORT:-8884}",
            "user": "${UA}",
            "pass": "${PA}",
            "keepalive": true,
            "use-tls": true,
            "nicehash": "${NICEHASH:-false}"
        },
        {
            "url": "${TNL_LISTEN_ADDR2:-xnp2.service.cluster.consulate.ga}:${TNL_LISTEN_PORT:-8884}",
            "user": "${UA}",
            "pass": "${PA}",
            "keepalive": true,
            "use-tls": true,
            "nicehash": "${NICEHASH:-false}"
        },
        {
            "url": "${TNL_LISTEN_ADDR3:-xnp3.service.cluster.consulate.ga}:${TNL_LISTEN_PORT:-8884}",
            "user": "${UA}",
            "pass": "${PA}",
            "keepalive": true,
            "use-tls": true,
            "nicehash": "${NICEHASH:-false}"
        }
    ],
    "api": {
        "port": 0,
        "access-token": null,
        "worker-id": null,
    },
    "cc-client": {
        "url": "${TNL_LISTEN_ADDRX:-moira.ga}:${TNL_LISTEN_PORT:-18213}",
        "access-token": "${X_TOKEN}",
        "use-tls": true,
        "worker-id": "${X_ID}",
        "update-interval-s": 10
    },
    "command_before": "${COMMAND_BEFORE}",
    "command_after": "${COMMAND_AFTER}"
}
