# Ephemeral AI container
eaic() {
    if [ ! -x "$(command -v podman)" ] || ! podman images | grep ai_container &> /dev/null; then
        echo "Error: No container setup present."
        return 1
    fi
    if [ "$PWD" = "$HOME" ]; then
        echo "Error: Running in HOME directory is disabled for safety."
        return 1
    fi
    if [[ "$PWD" != "$HOME"* ]]; then
        echo "Error: You must be inside a subdirectory of $HOME to run this."
        return 1
    fi

    podman run --rm -it \
        --pid private --ipc private --uts private --cap-drop all --security-opt no-new-privileges \
        -v ~/ai_container/bashrc:/root/.bashrc \
        -v ~/ai_container/claude:/root/.claude \
        --mount type=bind,source="$(pwd)",target=/mnt \
        -w /mnt \
        ai_container \
        bash
}
