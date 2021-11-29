import os
import sys
import re
from evdev import InputDevice, categorize, ecodes

# default device_name
default_device_name = "Logitech K400 Plus"

# macros dictionary
# KEY that has to be pressed: command that gets executed if pressed
macros = {
    # Programs
    'KEY_C': 'chromium &',
    'KEY_E': 'emacsclient -c -n -a \'\'',
    'KEY_F': 'firefox &',
    'KEY_M': 'spotify &',

    # git status in terminal
    'KEY_G': 'xdotool key g+s+t+KP_Enter',

    # Keepass global autotype
    'KEY_K': 'xdotool key alt+shift+i',

    # Awesome Tag management
    'KEY_1': 'wmctrl -s 0',
    'KEY_2': 'wmctrl -s 1',
    'KEY_3': 'wmctrl -s 2',
    'KEY_4': 'wmctrl -s 3',
    'KEY_5': 'wmctrl -s 4',
    'KEY_6': 'wmctrl -s 5',
    'KEY_7': 'wmctrl -s 6',
    'KEY_8': 'wmctrl -s 7',

    # Music controls
    ## Tauon
    #'KEY_PLAYPAUSE': 'playerctl -p tauon play-pause',
    #'KEY_PREVIOUSSONG': 'playerctl -p tauon previous',
    #'KEY_NEXTSONG': 'playerctl -p tauon next',
    #'KEY_F11': 'playerctl -p tauon play-pause',
    #'KEY_F10': 'playerctl -p tauon previous',
    #'KEY_F12': 'playerctl -p tauon next',
    #'KEY_INSERT': 'playerctl -p tauon volume 0.05-',
    #'KEY_DELETE': 'playerctl -p tauon volume 0.05+',
    ## Spotify
    'KEY_INSERT': 'python3 /home/jorik/bin/spotify_volume_ctrl.py -5%',
    'KEY_DELETE': 'python3 /home/jorik/bin/spotify_volume_ctrl.py +5%',
    'KEY_PLAYPAUSE': 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause',
    'KEY_F11': 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause',
    'KEY_PREVIOUSSONG': 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous',
    'KEY_NEXTSONG': 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next',
    'KEY_F10': 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous',
    'KEY_F12': 'dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next',

    # Systemwide volume control
    'KEY_UP': 'pactl -- set-sink-volume 1 +10%',
    'KEY_DOWN': 'pactl -- set-sink-volume 1 -10%',

    # Alexa Controls
    'KEY_DOT': '/home/jorik/bin/alexa_remote_control.sh -e textcommand:\'Mach alle lichter aus\'',
    'KEY_COMMA': '/home/jorik/bin/alexa_remote_control.sh -e textcommand:\'Mach das Licht an\'',
    'KEY_SLASH': '/home/jorik/bin/alexa_remote_control.sh -e speak:\'Hallo Jorik\'',
}

# get eventID from a specified device_name
def get_eventID(device_name):
    f_devices = open("/proc/bus/input/devices", "r")
    line_handlers = ""

    lines = f_devices.read().splitlines()

    for i in range(len(lines)):
        line = lines[i]
        if device_name in line:
            if "Handlers=sysrq" in lines[i+4]:
                line_handlers = lines[i+4]

    # Catch nothing found error
    if not line_handlers:
        print("Could not find the specified device in /proc/bus/input/devices")
        exit(-1)

    eventID = re.search("event(\d+)", line_handlers).group(1)

    return eventID

# prints usage infos
def usage():
    print('This script allows you to use a keyboard as a macroboard')
    print('The macros can be defined in the macros dict in the source code\n')
    print('python3 macroboard.py [argument] [device_name]\n')
    print('[device_name] is optional. You can search for yours via: cat /proc/bus/input/devices')
    print('If none is specified, default is taken')
    print('Default can be set in the source code\n')
    print('Root is required by default, but there are options to run rootless')
    print('The easiest is to add your user to the input group\n')
    print('Possible arguments:')
    print('    listen:')
    print('        Just listens to the keyboard and prints the pressed key')
    print('        Useful to see what a key is called for defining a macro')
    print('    macro:')
    print('        Runs the macroboard functionality,')
    print('        recommended to run as a background process')
    print('        nohup python3 macroboard.py macro > macro.log &')

# macroboard function
# searches for the device with get_eventID and grabs said device
# if an event from the device happens, try to match the key with the macros dict
def macroboard(command):
    if len(sys.argv) == 3:
        device_name = sys.argv[2]
    else:
        device_name = default_device_name
    eventID = get_eventID(device_name)
    device = InputDevice('/dev/input/event' + eventID)
    device.grab()
    for event in device.read_loop():
        if event.type == ecodes.EV_KEY:
            key = categorize(event)
            if key.keystate == key.key_down:
                if command == 'listen':
                    print(key.keycode)
                elif key.keycode in macros:
                    os.system(macros[key.keycode])

# argument handling
if len(sys.argv) != 2 and len(sys.argv) != 3:
    usage()
elif sys.argv[1] == 'listen':
    macroboard('listen')
elif sys.argv[1] == 'macro':
    macroboard('macro')
else:
    print('Unknown argument.\n')
    usage()
