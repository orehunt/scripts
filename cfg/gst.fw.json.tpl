{
    "Debug": false,
    "Retries": 3,
    "ServeNodes": [
        "${TNL_PROTO_PC:-socks5}://${TNL_USR:-tnluser}:${TNL_PASS:-tnlpass123}@:${TNL_LISTEN:-8080}/${TNL_TARGET}",
        ":${FW_SRC:-8081}/:${FW_DST:-18213}"
    ],
    "ChainNodes": [
        "${TNL_PROTO:-socks5+kcp}://chacha20:123@${TNL_REMOTE}:${TNL_PORT:-18214}?ttl=60"
    ],
    "Routes": [
        {
            "Retries": 3,
            "ServeNodes": [
            ],
            "ChainNodes": [
            ]
        },
        {
            "Retries": 3,
            "ServeNodes": []
        }
    ]
}
