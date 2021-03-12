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
        "init": ${RX_INIT:-0},
        "mode": "auto",
        "1gb-pages": false,
        "rdmsr": true,
        "wrmsr": true,
        "numa": true
    },
    "cpu": {
        "enabled": true,
        "huge-pages": null,
        "hw-aes": ${AESNI:-null},
        "sleep" : ${CSLEEP:-0},
        "priority": null,
        "memory-pool": false,
        "yield": true,
        "max-threads-hint": 100,
        "asm": true,
        "argon2-impl": null,
        "astrobwt-max-size": 550,
        "*": {
            "threads": ${THREADS:-null},
            "intensity": null,
            "enabled": true
        },
        "rx/0": ${RX_ENABLED:-true},
        "rx/arq": ${RX_ENABLED:-true},
        "rx/loki": ${RX_ENABLED:-true},
        "rx/wow": ${RX_ENABLED:-true},
        "rx/keva": ${RX_ENABLED:-true},
        "rx/panthera": ${RX_ENABLED:-true},
        "rx/sfx": ${RX_ENABLED:-true}
    },
    "donate-level": 0,
    "donate-over-proxy": 0,
    "log-file": null,
    "pools": [
        ${POOLS}
    ],
    "cc-client": {
        "enabled": false,
        "use-tls": true,
        "use-remote-logging": false,
        "upload-config-on-start": true,
        "url": "${X_URL}",
        "access-token": "${X_TOKEN}",
        "worker-id": "${X_ID}",
        "reboot-cmd": null,
        "update-interval-s": 30
    },
    "print-time": 360,
    "retries": 1,
    "retry-pause": 1,
    "syslog": false,
    "user-agent": null,
    "watch": true,
    "daemonized": true
}
