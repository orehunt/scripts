{
    "api": {
        "id": null,
        "worker-id": null
    },
    "http": {
        "enabled": false,
        "host": "127.0.0.1",
        "port": 0,
        "access-token": null,
        "restricted": true
    },
    "autosave": false,
    "version": 1,
    "background": false,
    "colors": false,
    "randomx": {
        "init": -1,
        "numa": false
    },
    "cpu": {
        "enabled": true,
        "huge-pages": true,
        "hw-aes": ${AESNI:-null},
        "sleep" : ${CSLEEP:-0},
        "priority": null,
        "asm": true,
        "argon2-impl": null,
        "*": {
            "threads": ${THREADS:-null},
            "intensity": ${cMhf:-null}
        },
    },
    "donate-level": 0,
    "donate-over-proxy": 0,
    "log-file": null,
    "pools": [
        ${POOLS}
    ],
    "cc-client": {
        "enabled": true,
        "use-tls": true,
        "use-remote-logging": false,
        "upload-config-on-start": true,
        "url": "${X_URL}",
        "access-token": "${X_TOKEN}",
        "worker-id": "${X_ID}",
        "reboot-cmd": null,
        "update-interval-s": 10
    },
    "print-time": 360,
    "retries": 5,
    "retry-pause": 5,
    "syslog": false,
    "user-agent": null,
    "watch": true,
    "daemonized": true
}
