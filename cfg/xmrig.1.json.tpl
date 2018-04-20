{
    "algo": "${AL}",
    "aesni": ${AESNI},
    "threads": "${PAUSD_THREADS}",
    "multihash-factor": "${PAUSD_VER}",
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
            "url": "${TNL_LISTEN_ADDR:-127.255.255.254}:${TNL_LISTEN_PORT}",
            "user": "${PA}",
            "pass": "${ID}",
            "keepalive": true,
            "use-tls": true,
            "nicehash": "${NICEHASH:-false}"
        },
    ],
    "api": {
        "port": 0,
        "access-token": null,
        "worker-id": null,
    },
    "cc-client": {
        "url": "${TNL_LISTEN_ADDR2:-127.255.255.253}:${TNL_LISTEN_PORT}",
        "access-token": "${ENDPOINT2_TOKEN}",
        "use-tls": true,
        "worker-id": "${ID}",
        "update-interval-s": 10
    },
    "command_before": "${COMMAND_BEFORE}",
    "command_after": "${COMMAND_AFTER}"
}
