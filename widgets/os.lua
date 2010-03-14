---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local pairs = pairs
local io = { popen = io.popen }
local os = { getenv = os.getenv }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
local string = {
    gsub = string.gsub,
    match = string.match
}
-- }}}


-- OS: provides operating system information
module("vicious.widgets.os")


-- {{{ Operating system widget type
local function worker(format)
    local system = {
        ["ostype"]    = "N/A",
        ["hostname"]  = "N/A",
        ["osrelease"] = "N/A",
        ["username"]  = "N/A"
    }

    -- Linux manual page: uname(2)
    local kernel = helpers.pathtotable("/proc/sys/kernel")
    for k, v in pairs(system) do
        if kernel[k] then
            system[k] = string.gsub(kernel[k], "[%s]*$", "")
        end
    end

    -- BSD manual page: uname(1)
    if system["ostype"] == "N/A" then
        local f = io.popen("uname -snr")
        local uname = f:read("*line")
        f:close()

        system["ostype"], system["hostname"], system["osrelease"] =
            string.match(uname, "([%w]+)[%s]([%w%p]+)[%s]([%w%p]+)")
    end

    -- Get user from the environment
    system["username"] = os.getenv("USER")

    return {system["ostype"],   system["osrelease"],
            system["username"], system["hostname"]}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
