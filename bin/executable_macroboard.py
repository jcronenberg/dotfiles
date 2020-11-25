import os
import sys
import re
from evdev import InputDevice, categorize, ecodes

# Macros dictionary
# KEY that has to be pressed: Command that gets executed if pressed
# Note that commands are run as sudo. For commands that need to be run
# as another user use 'su username -c "command"'
macros = {
    'KEY_C': 'chromium &',
    'KEY_E': 'emacsclient -c -n -a \'\'',
    'KEY_F': 'firefox &',
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
    # MPD controls
    'KEY_PLAYPAUSE': 'mpc toggle',
    'KEY_PREVIOUSSONG': 'mpc prev',
    'KEY_NEXTSONG': 'mpc next',
    'KEY_INSERT': 'mpc volume -5',
    'KEY_DELETE': 'mpc volume +5',
    # Systemwide volume control
    'KEY_VOLUMEUP': 'pactl -- set-sink-volume 1 +10%',
    'KEY_VOLUMEDOWN': 'pactl -- set-sink-volume 1 -10%',
}

# Input id
# To find the right one: cat /proc/bus/input/devices
# Match the name and look for the line that says something like:
# Handlers=sysrq kbd event{number}
# The sysrq at the beginning is important others that have same name
# but not the sysrq won't work
def get_eventID(device_name):
    f_devices = open("/proc/bus/input/devices", "r")
    line_handlers = ""

    lines = f_devices.read().splitlines()

    for i in range(len(lines)):
        line = lines[i]
        if device_name in line:
            if "Handlers=sysrq" in lines[i+4]:
                line_handlers = lines[i+4]

    eventID = re.search("event(\d+)", line_handlers).group(1)

    return eventID

# Prints usage infos
def usage():
    print('This script allows you to use a second keyboard as a macroboard')
    print('The macros can be defined in the macros dict in the source code')
    print('python3 macroboard.py [argument] [eventID]\n')
    print('[eventID] is optional. If your keyboard is for example event5 input \'5\' ')
    print('If none is specified, default is taken')
    print('Default can be set in the source code\n')
    print('Possible arguments:')
    print('    listen:')
    print('        Just listens to the keyboard and prints the pressed key')
    print('        Useful to see what a key is called for defining a macro')
    print('    macro:')
    print('        Runs the macroboard functionality,')
    print('        recommended to run as a background process')
    print('        sudo nohup python3 macroboard.py macro > macro.log &')

# Main function
def macroboard(command):
    if len(sys.argv) == 3:
        device_name = sys.argv[2]
    else:
        device_name = "Logitech K400 Plus"
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

# Check arguments
if len(sys.argv) != 2 and len(sys.argv) != 3:
    usage()
elif sys.argv[1] == 'listen':
    macroboard('listen')
elif sys.argv[1] == 'macro':
    macroboard('macro')
else:
    print('Unknown argument.\n')
    usage()
