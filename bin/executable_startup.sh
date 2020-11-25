#!/bin/sh
if [ -n "$1" ]; then
    nohup python3 bin/macroboard.py macro "$1" > bin/macro.log &
else
    nohup python3 bin/macroboard.py macro > bin/macro.log &
fi
emacs -nw --daemon
tmux new-session -d 'neomutt'
tmux new-window 'ncmpcpp'
tmux attach
