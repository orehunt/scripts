{
    "algo": "${AL}",
    "aesni": 1,
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
            "url": "${ENDPOINT}",
            "user": "${PA}",
            "pass": "${ID}",
            "keepalive": true,
            "nicehash": false
        },
    ],
    "api": {
        "port": 0,
        "access-token": null,
        "worker-id": null,
    },
    "cc-client": {
        "url": "${ENDPOINT2}",
        "access-token": "${ENDPOINT2_TOKEN}",
        "worker-id": "${ID}",
        "update-interval-s": 10
    }
}
