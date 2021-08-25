
Jim Buzbee
JimBuzbee@gmail.com
http://batbox.org/
8/24/2021

Simple Bash script to control my Govee strip LED Lights from my Raspberry Pi

Why bash instead of a more appropriate language? No Dependencies besides
standard bluetooth tools. No pip installs, no npm installs.  All you need is a
functioning bluetooth stack, bash and the standard "gatttool" tool. I've been
using this on a Raspberry Pi, but I assume it will work on any Linux system with
bluetooth and gatttool. I've only tested this with my Govee LED strips, Hardware
Version 1.00.01, Model H6141 but it may work with other Govee devices.

My needs are small, thus only the follwing commands are implemented:
   turnOn ID
   turnOff ID
   setColor ID ColorName or R G B
   setBrightness ID 0-100

See the script for details and examples. Change the device ID(s) to match yours.

Use "sudo hcitool lescan" to find the ID of your devices. The names for mine started
with "ihoment_". You can use this alongside the standard Govee control App, but you
can only use one at a time.

Note the following hack to restart bluetooth at the start of the script:

hciconfig hci0 down
hciconfig hci0 up

At least on my system, this was the only way to make behavior consistent.  Your
mileage may vary and if you're using other bluetooth devices, take care. And this
also means that you'll have to run this with sudo. Comment those lines out and if
you are able to run without restarting the bluetooth device, you will not have to
use sudo.

Also note that the gatttool command used to send data to the lightstrip is in
a loop because it sometimes fails due to the vagaries of bluetooth and/or the
Linux stack or Govee implementation. On failure, an error will be seen on screen,
but for me it always recovers


This would not have been possible without work from others:

https://github.com/egold555/Govee-H6113-Reverse-Engineering
https://community.home-assistant.io/t/govee-bluetooth-lights/262736
https://github.com/ddxtanx/GoveeAPI



Jim Buzbee
JimBuzbee@gmail.com
http://batbox.org/
8/24/2021


# Bash-Govee
