{
    "algo": "${AL}",
    "aesni": ${AESNI},
    "pow-variant": "${AL_V:-2}",
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
        ${POOLS}
    ],
    "api": {
        "port": 0,
        "access-token": null,
        "worker-id": null,
    },
    "cc-client": {
        "url": "${X_URL}",
        "access-token": "${X_TOKEN}",
        "use-tls": true,
        "worker-id": "${X_ID}",
        "update-interval-s": 10
    },
    "command_before": "${COMMAND_BEFORE}",
    "command_after": "${COMMAND_AFTER}"
}
