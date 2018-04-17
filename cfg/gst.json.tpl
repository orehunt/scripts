{
    "Debug": false,
    "Retries": 3,
    "ServeNodes": [
        "${TNL_LISTEN_SCHEME:-tcp}://${TNL_LISTEN_ADDR:-127.255.255.254}:${TNL_LISTEN_PORT:-8080}/${TNL_LISTEN_TARGET}",
        "${TNL_LISTEN_SCHEME:-tcp}://${TNL_LISTEN_ADDR2:-127.255.255.253}:${TNL_LISTEN_PORT:-8080}/${TNL_LISTEN_TARGET2}"
    ],
    "ChainNodes": [
        "${TNL_FORWARD_SCHEME:-ss+kcp}://chacha20:123@${TNL_FORWARD_ADDR}:${TNL_FORWARD_PORT:-18214}?${TNL_FORWARD_ARGS}ttl=60"
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
