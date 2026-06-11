podman build -t ai_container --pull=newer --cache-ttl=1h . && podman image prune --filter "label=ai_container"
