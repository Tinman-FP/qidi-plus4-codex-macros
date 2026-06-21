#!/bin/bash

# Read the last recorded G-code line
number=$(cat /home/pi/scripts/plr/plr_record)

# Confirm the value is numeric
if ! [[ $number =~ ^[0-9]+$ ]] ; then
   echo "Error: No valid number found in /home/pi/scripts/plr/plr_record"
   exit 1
fi

# Check whether gcode_lines already exists
if grep -q "^gcode_lines = " /home/pi/printer_data/config/saved_variables.cfg; then
    # Update gcode_lines when present
    sed -i "s/^gcode_lines = [0-9]*/gcode_lines = $number/" /home/pi/printer_data/config/saved_variables.cfg
else
    # Add gcode_lines when missing
    echo "gcode_lines = $number" >> /home/pi/printer_data/config/saved_variables.cfg
fi
