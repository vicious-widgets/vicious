---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Boris Bolgradov <>
--
-- This widget type depends on luasocket.
--
-- Widget arguments are host, port, username and
-- password, i.e.:
--    {"mail.myhost.com", 110, "John", "132435"}
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local sock_avail, socket = pcall(function()
    return require("socket")
end)
-- }}}


-- POP: provides the count of new messages in a POP3 mailbox
module("vicious.contrib.pop")


-- {{{ POP3 count widget type
local function worker(format, warg)
    if not sock_avail or (not warg or #warg ~= 4) then
        return {"N/A"}
    end

    local host, port = warg[1], tonumber(warg[2])
    local user, pass = warg[3], warg[4]

    local client = socket.tcp()
    client:settimeout(3)
    client:connect(host, port)
    client:receive("*l")
    client:send("USER " .. user .. "\r\n")
    client:receive("*l")
    client:send("PASS " .. pass .. "\r\n")
    client:receive("*l")
    client:send("STAT" .. "\r\n")
    local response = client:receive("*l")
    client:close()

    if response:find("%+OK") then
        response = response:match("%+OK (%d+)")
    end

    return {response}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
