# FootFallField
Lidar/projector/Processing malarkey for EMF2016

https://youtu.be/J-ZNvXCDj2k
https://www.youtube.com/watch?v=N5BPqdGWPn0

FootFallField is a collective plaything, which uses a lidar scanner to capture foot positions 
over a rectangle of floor and a projector to project foot-responsive effects onto that floor.

The scanner uses a LIDAR-Lite sensor from Pulsed Light (now taken over by Garmin, sensor is not available at time of writing) and a lasercut rotating-mirror scanning mechanism. It has two Arduino Nanos, one to run the motor and one to read the scanner and forward range information over USB.

That goes to a Pi 3 running Processing, which infers foot positions from range data and generates the effects.

If you want to tinker, the Processing code has a debug mode in which it'll run without the scanner, simulate footsteps, and accept footsteps from mouse clicks. That makes it very easy to develop new effects without using the scanner and projector.

See http://jarkman.co.uk/catalog/robots/footfallfield.htm for more.

Notes for running on Pi:

We want a low resolution for more speed, so 

$ sudo nano /boot/config.txt
 then uncomment/edit to set the hdmi mode to (eg)
hdmi_group=11
hdmi_mode=18

See http://elinux.org/RPi_Configuration for a list of modes.

You also need to disable the screensaver, I did all the things listed here:
https://www.raspberrypi.org/forums/viewtopic.php?f=66&t=18200
