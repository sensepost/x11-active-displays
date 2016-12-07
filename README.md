# X11-Active-Diplays

Checks if you're allowed to connect to the X server. Outputs a screenshot to of the display if allowed and the display is active. This script can can only run on Linux with the correct dependencies. If the X server is listening on TCP port 6000+N where N is the display number, it is possible to check if you're able to connect to the remote display by sending an X11 initial connection request. Then using the X tool ```xwininfo``` it is possible to check if the display is active, the X tool ```xset``` allows disabling the screensaver and the imagemagick tool ```import``` outputs a screenshot of the display and ```xset``` re-enables the screensaver. If the screensaver was not active, this will activate it; thus this script is not safe. If a user is looking at the display, this will be noticed.

Disabling and re-enabling the screensaver will only occur if the ```unsafe``` argument is set. Otherwise a screenshot will be taken without disabling the screensaver.

If the ```dir``` argument is to a directory, the screenshot will be saved to the given directory. Ensure the user running the scan has write privileges in the given directory.

This script is based on the x11-access.nse script by vladz.

Once you've found a vulnerable host, check out our tool for exploiting it [here](https://github.com/sensepost/xrdp).

## Usage
```
nmap -p6000 <host> --script x11-active-displays.nse
nmap -p6000 <host> --script x11-active-displays.nse --script-args=unsafe=1,dir="/home/<username>/Documents/"
```

## Output
```
Host script results:
| x11-active-displays: X server access is granted
|     Active display
|_    Screenshot saved to /tmp/<ip>:<dp>.jpg
Host script results:
| x11-active-displays: X server access is granted
|_    No active display
```

## Arguments
```
unsafe
```
If set, this script will run disable the screensaver before attempting to take a screenshot and reenable it after taking the screenshot.
```	
dir
```
If set to a directory, the output screenshots will be saved there. Otherwise, default to the /tmp/ directory.
	
## Dependancies
xwininfo

import

## Authors:
Darryn@SensePost.com

Thomas@SensePost.com

