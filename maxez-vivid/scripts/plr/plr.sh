#!/bin/bash

# Define config paths
SD_PATH="/home/pi/printer_data/gcodes/.plr"
CONFIG_FILE="/home/pi/printer_data/config/saved_variables.cfg"

# Initialize variables
BED_TEMP=""
GCODE_LINES=""
CHAMBER_TEMP=""
EXTRUDER_TEMP=""

BED_TEMP=$(awk -F " = " '/bed_temp/ {gsub(/'\''/, "", $2); print $2}' $CONFIG_FILE)
GCODE_LINES=$(awk -F " = " '/gcode_lines/ {gsub(/'\''/, "", $2); print $2}' $CONFIG_FILE)
CHAMBER_TEMP=$(awk -F " = " '/hot_temp/ {gsub(/'\''/, "", $2); print $2}' $CONFIG_FILE)
EXTRUDER_TEMP=$(awk -F " = " '/print_temp/ {gsub(/'\''/, "", $2); print $2}' $CONFIG_FILE)

echo ""
echo "Running Power loss recovery"
echo "GCODE_LINES: $GCODE_LINES"
echo "EXTRUDER_TEMP: $EXTRUDER_TEMP"
echo "BED_TEMP: $BED_TEMP"
echo "CHAMBER_TEMP: $CHAMBER_TEMP"

mkdir -p /home/pi/printer_data/gcodes/.plr
rm -f /home/pi/printer_data/gcodes/.plr/plr.gcode

GCODE_PATH=$(find /home/pi/printer_data/gcodes/.cache/ -maxdepth 1 -name "*.gcode" -print -quit)

cat "${GCODE_PATH}" > /tmp/plrtmpA.$$
num_lines=$(($GCODE_LINES - 1))
content=$(head -n $num_lines /tmp/plrtmpA.$$)
isInFile=$(cat /tmp/plrtmpA.$$ | grep -c "thumbnail")
z_position=$(echo "$content" | sed -n '/;Z:/s/.*;Z:\([0-9.]*\).*/\1/p' | tail -n 1)
if [ -z "$z_position" ]; then
    z_position=$(echo "$content" | sed -n '/; Z_HEIGHT: /s/.*;\x20Z_HEIGHT:\x20\([0-9.]*\).*/\1/p' | tail -n 1)
fi

# Find the thumbnails
if [ $isInFile -ne 0 ]; then
    sed -i '1s/^/;start copy\n/' /tmp/plrtmpA.$$
    sed -n '/;start copy/, /thumbnail end/ p' < /tmp/plrtmpA.$$ > ${SD_PATH}/plr.gcode
    echo ';' >> ${SD_PATH}/plr.gcode
    echo '' >> ${SD_PATH}/plr.gcode
fi

echo "SET_KINEMATIC_POSITION Z="${z_position} >> ${SD_PATH}/plr.gcode

# Preheat
echo 'M109 S'${EXTRUDER_TEMP} >> ${SD_PATH}/plr.gcode
echo 'M140 S'${BED_TEMP} >> ${SD_PATH}/plr.gcode
echo 'M104 S'${EXTRUDER_TEMP} >> ${SD_PATH}/plr.gcode

# Lower Z axis, home
echo 'G91' >> ${SD_PATH}/plr.gcode
echo 'G1 Z5' >> ${SD_PATH}/plr.gcode
echo 'G90' >> ${SD_PATH}/plr.gcode
echo 'G28 X Y' >> ${SD_PATH}/plr.gcode
echo 'G28 X' >> ${SD_PATH}/plr.gcode

echo 'CLEAR_NOZZLE_PLR hotend='${EXTRUDER_TEMP} >> ${SD_PATH}/plr.gcode

# Wait for temperature
echo 'M190 S'${BED_TEMP} >> ${SD_PATH}/plr.gcode
echo 'M191 S'${CHAMBER_TEMP} >> ${SD_PATH}/plr.gcode

# Fan
echo "$content" | sed -n '1,'${num_lines}' {/M106/ p}' >> ${SD_PATH}/plr.gcode

# Back to the lost position
echo 'G90' >> ${SD_PATH}/plr.gcode
echo "G1 Z"${z_position} >> ${SD_PATH}/plr.gcode

# Extruder mode
cat /tmp/plrtmpA.$$ | sed -rn '1,'${num_lines}' {/(M83|M82)/ p}' | tail -n 1 >> ${SD_PATH}/plr.gcode

echo 'ENABLE_ALL_SENSOR' >> ${SD_PATH}/plr.gcode

echo 'G1 F6000' >> ${SD_PATH}/plr.gcode
cat /tmp/plrtmpA.$$ | sed -e  '1,'${num_lines}' d'>> ${SD_PATH}/plr.gcode

/bin/sleep 3
rm -f /tmp/plrtmpA.$$