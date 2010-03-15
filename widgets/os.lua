---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local pairs = pairs
local tonumber = tonumber
local io = { popen = io.popen }
local os = { getenv = os.getenv }
local math = { ceil = math.ceil }
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
        ["username"]  = "N/A",
        ["entropy"]   = "N/A",
        ["entropy_p"] = "N/A"
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

    -- Linux manual page: random(4)
    if kernel.random then
        -- Linux 2.6 default entropy pool is 4096-bits
        local poolsize = tonumber(kernel.random.poolsize)

        -- Get available entropy and calculate percentage
        system["entropy"]   = tonumber(kernel.random.entropy_avail)
        system["entropy_p"] = math.ceil(system["entropy"] * 100 / poolsize)
    end

    -- Get user from the environment
    system["username"] = os.getenv("USER")

    return {system["ostype"], system["osrelease"], system["username"],
            system["hostname"], system["entropy"], system["entropy_p"]}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
