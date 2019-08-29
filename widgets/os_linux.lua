---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local pairs = pairs
local tonumber = tonumber
local math = { ceil = math.ceil }
local los = { getenv = os.getenv }
local setmetatable = setmetatable
local string = { gsub = string.gsub }

local helpers = require"vicious.helpers"
-- }}}


-- OS: provides operating system information
-- vicious.widgets.os
local os_linux = {}


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
    for k, _ in pairs(system) do
        if kernel[k] then
            system[k] = string.gsub(kernel[k], "[%s]*$", "")
        end
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
    system["username"] = los.getenv("USER")

    return {system["ostype"], system["osrelease"], system["username"],
            system["hostname"], system["entropy"], system["entropy_p"]}
end
-- }}}

return setmetatable(os_linux,
                    { __call = function(_, ...) return worker(...) end })
