#!/usr/bin/env python3
#Author: Marcin Kocur, attribution license: https://creativecommons.org/licenses/by/4.0/
# slightly modified to reverse the order it searches for spotify
# as it sometimes for whatever reason seems to create another playback
# when casting to a device
# then the last playback is desired and not the first
import subprocess
import os
import sys
env = os.environ
env['LANG'] = 'en_US'
app = '"Spotify"'
pactl = subprocess.check_output(['pactl', 'list', 'sink-inputs'], env=env).decode().strip().split()
x=len(pactl) #original: x=0
y=0
if app in pactl:
    for e in reversed(pactl): #original: for e in pactl:
        x -= 1 #original: x += 1
        if e == app:
            break
    for i in pactl[0 : x -1 ]:
        y += 1
        if i == 'Sink' and pactl[y] == 'Input' and '#' in pactl[y + 1]:
            sink_id = pactl[y+1]
        if i == 'Volume:' and '%' in pactl[y + 3]:
            volume = pactl[y + 3]
    sink_id = sink_id[1: ]
    volume = volume[ : -1 ]
    subprocess.run(['pactl', 'set-sink-input-volume', sink_id, sys.argv[1]])
