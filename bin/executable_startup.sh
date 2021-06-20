#!/bin/sh

# Start macroboard script
if [ -n "$1" ]; then
    nohup python3 bin/macroboard.py macro "$1" > bin/macro.log &
else
    nohup python3 bin/macroboard.py macro > bin/macro.log &
fi

# Copy alexa login cookie
cp /home/jorik/bin/.alexa.cookie /tmp

# Start emacs daemon
emacs -nw --daemon

# Start tmux session
tmux new-session -d 'neomutt'
tmux new-window
tmux attach
