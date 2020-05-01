#!/usr/bin/env python

import sys
import os
from shlex import quote

for argument in sys.stdin:
    if 'mjt: ' in argument or 'mjturt: ' in argument:
        full = argument.split()
        sender = full[2]
        message = ' '.join(map(str, full[3:]))
        command = 'notify-send "✉️ IRC from {}" {}'.format(quote(sender), quote(message))
        os.system(command)
