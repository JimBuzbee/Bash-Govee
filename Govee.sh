#!/bin/bash

# Thanks for hints from
# https://community.home-assistant.io/t/govee-bluetooth-lights/262736
# https://github.com/ddxtanx/GoveeAPI
# https://github.com/egold555/Govee-H6113-Reverse-Engineering

# hack - sometimes needed
hciconfig hci0 down
hciconfig hci0 up

# use "sudo hcitool lescan" to find your devices. Look for "ihoment_*"
# change these accordingly
Strip1="A4:C1:38:B5:C7:42"
Strip2="A4:C1:38:84:F6:95"

# add or chnage as see fit
declare -A colors=(
                    [green]="0,255,0"
                    [blue]="0,0,255"
                    [white]="255,255,255"
                    [tomato]="165,99,71"
                    [orange]="255,165,0"
                    [black]="0,0,0"
                    [white]="255,255,255"
                    [red]="255,0,0"
                    [lime]="0,255,0"
                    [green]="0,255,0"
                    [blue]="0,0,255"
                    [yellow]="255,255,0"
                    [cyan]="0,255,255"
                    [magenta]="255,0,255"
                    [silver]="192,192,192"
                    [gray]="128,128,128"
                    [maroon]="128,0,0"
                    [olive]="128,128,0"
                    [green]="0,128,0"
                    [purple]="128,0,128"
                    [teal]="0,128,128"
                    [navy]="0,0,128"
                  )
###############################################################

# sorry about the hard-coded numbers seen when commands
# are constructed. It's not clear what they represent, but
# were seen when others reverse-engineered the protocol

###############################################################
sendData() {
   # try max 5 times to account for transient errors
   for i in {1..5}; do gatttool --char-write-req -b $1 -a 0x0015 -n $2 >/dev/null && break || sleep 0.5; done
}
###############################################################
turnOn () {
   sendData $1 3301010000000000000000000000000000000033
}
###############################################################
turnOff() {
   sendData $1 3301000000000000000000000000000000000032
}
###############################################################
setColor() {
   if [ "$#" -ne 4 ]; then # not enough args for r g b, assume color name
      c="${2:-gray}" # default to gray if nothing passed
      c=${colors[$(echo "$c" | tr '[:upper:]' '[:lower:]')]}
      r=$(echo $c | cut -f 1 -d,)
      g=$(echo $c | cut -f 2 -d,)
      b=$(echo $c | cut -f 3 -d,)
   else
      r=$2; g=$3; b=$4;
   fi
   setRGBColor $1 $r $g $b
}
###############################################################
setRGBColor() {
   r="${2:-127}"
   g="${3:-127}"
   b="${4:-127}"

   checksum=$(((3*16 + 1) ^ r ^ g ^ b))
   sendData $1 $(printf '%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x000000000000000000%02x' 51 5 2 $r $g $b 0 255 174 84 $checksum)
}
###############################################################
setBrightness() {
   # scale 0-100 to 0-255
   brightness=$(($2 * 255/100))
   sendData $1 $(printf '%02x%02x%02x00000000000000000000000000000000%02x' 51 4 $brightness $(( 51 ^ 4 ^ $brightness )))
}
###############################################################

# The below are just examples - change as desired

setBrightness $Strip1 100
setBrightness $Strip2 100

turnOn $Strip1
turnOn $Strip2

setColor $Strip1 $1
setColor $Strip2 $1

# setColor $Strip2 blue
# setColor $Strip1 ORANGE
# setColor $Strip1 127 64 255

# 100 down to 50 in increments of -5
for j in $(seq 100 -5 50)
do
   setBrightness $Strip1 $j
   setBrightness $Strip2 $j
done

if [ "$2" = "off" ]; then
   turnOff $Strip2
   turnOff $Strip1
fi

