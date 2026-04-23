#!/bin/bash
sleep 5 # Increased sleep to ensure USB device is ready

# 1. Create the Virtual Sink
pactl load-module module-null-sink sink_name=Virtual_Mic sink_properties=device.description=Virtual_Mic

# 2. Set the physical mic volume (The "Generalplus" device)
# We use the full name to ensure it hits the right hardware
pactl set-source-volume alsa_input.usb-Generalplus_Usb_Audio_Device-00.mono-fallback 25%

# 3. Connect the physical mic to the Virtual Sink
pactl load-module module-loopback source=alsa_input.usb-Generalplus_Usb_Audio_Device-00.mono-fallback sink=Virtual_Mic latency_msec=1
