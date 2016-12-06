local nmap = require "nmap"
local string = require "string"
local os = require "os"

-- NSE x11-active-displays v1.0

description = [[
Checks if you're allowed to connect to the X server. Outputs a screenshot to of the display if allowed and the display is active. This script can can only run on Linux with the correct dependencies. If the X server is listening on TCP port 6000+N where N is the display number, it is possible to check if you're able to connect to the remote display by sending an X11 initial connection request. Then using the X tool xwininfo it is possible to check if the display is active, the X tool xset allows disabling the screensaver and the imagemagick tool import outputs a screenshot of the display and xset re-enables the screensaver. If the screensaver was not active, this will activate it; thus this script is not safe. If a user is looking at the display, this will be noticed.

Disabling and re-enabling the screensaver will only occur if the unsafe argument is set. Otherwise a screenshot will be taken without disabling the screensaver.

If the dir argument is to a directory, the screenshot will be saved to the given directory. Ensure the user running the scan has write privileges in the given directory.

This script is based on the x11-access.nse script by vladz.
]]

---
--@usage
--     nmap -p6000 <host> --script x11-active-displays.nse
--     nmap -p6000 <host> --script x11-active-displays.nse --script-args=unsafe=1,dir="/home/<username>/Documents/"
--
---
-- @output
--    Host script results:
--     | x11-active-displays: X server access is granted
--     |     Active display
--     |_    Screenshot saved to /tmp/<ip>:<dp>.jpg
--     Host script results:
--     | x11-active-displays: X server access is granted
--     |_    No active display
--
---
-- @args unsafe If set, this script will run disable the screensaver before
--     attempting to take a screenshot and reenable it after taking the
--     screenshot
-- @args dir If set to a directory, the output screenshots will be saved
--     there. Otherwise, default to the /tmp/ directory.
--

author = "Darryn Cull"
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"
categories = {"default", "auth", "safe"}
dependencies = {"xwininfo", "xset", "import"}

portrule = function(host, port)
    return ((port.number >= 6000 and port.number <= 6009)
        or (port.service and string.match(port.service, "^X11")))
        and port.version.product == nil
end

action = function(host, port)
    local result, socket, try, catch
    socket = nmap.new_socket()
    catch = function()
            socket:close()
    end

    try = nmap.new_try(catch)
    try(socket:connect(host, port))

    try(socket:send("\108\000\011\000\000\000\000\000\000\000\000\000"))

    result = try(socket:receive_bytes(1))
    socket:close()

    if string.match(result, "^\001") then
        local display = host.ip .. ":" .. (port.number - 6000)
        local dir = "/tmp/"

        if (nmap.registry.args.dir ~= nil) then
            dir = nmap.registry.args.dir
            if (string.sub(dir, string.len(dir)) ~= "/") then
                dir = dir .. "/"
            end
        end

		local ret1, ret2, ret3 = os.execute("xwininfo -root -display " .. display .. " > /dev/null 2>&1")

        if (ret3 == 0) then
            if (nmap.registry.args.unsafe ~= nil) then
                os.execute("xset -display " .. display .. " s reset")
                local t0 = os.clock()
                while os.clock() - t0 <= 1 do end
            end

            os.execute("DISPLAY=" .. display .. " import -window root ".. dir .. display .. ".png")

            if (nmap.registry.args.unsafe ~= nil) then
                os.execute("xset -display " .. display .. " s activate  > /dev/null 2>&1")
            end

            return "X server access is granted\n\tActive diplay\n\tScreenshot saved to " .. dir .. "<ip>:<dp>.jpg"
        else
            return "X server access is granted\n\tNo active display"
        end
    end
end
