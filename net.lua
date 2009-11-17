---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Henning Glawe <glaweh@debian.org>
--  * (c) 2008, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local os = { time = os.time }
local io = { open = io.open }
local setmetatable = setmetatable
local string = {
    match = string.match,
    format = string.format
}
-- }}}


-- Net: provides usage statistics for all network interfaces
module("vicious.net")


-- Initialise function tables
local nets = {}

-- {{{ Helper functions
local function uformat(array, key, value)
    array["{"..key.."_b}"]  = string.format("%.1f", value)
    array["{"..key.."_kb}"] = string.format("%.1f", value/1024)
    array["{"..key.."_mb}"] = string.format("%.1f", value/1024/1024)
    array["{"..key.."_gb}"] = string.format("%.1f", value/1024/1024/1024)
    return array
end
-- }}}

-- {{{ Net widget type
local function worker(format)
    -- Get /proc/net/dev
    local f = io.open("/proc/net/dev")
    local args = {}

    for line in f:lines() do
        -- Match wmaster0 as well as rt0 (multiple leading spaces)
        if string.match(line, "^[%s]?[%s]?[%s]?[%s]?[%w]+:") then
            local name = string.match(line, "^[%s]?[%s]?[%s]?[%s]?([%w]+):")
            -- Received bytes, first value after the name
            local recv = tonumber(string.match(line, ":[%s]*([%d]+)"))
            -- Transmited bytes, 7 fields from end of the line
            local send = tonumber(string.match(line,
             "([%d]+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d$"))

            uformat(args, name .. " rx", recv)
            uformat(args, name .. " tx", send)

            if nets[name] == nil then 
                -- Default values on the first run
                nets[name] = {}
                uformat(args, name .. " down", 0)
                uformat(args, name .. " up", 0)

                nets[name].time = os.time()
            else
                -- Net stats are absolute, substract our last reading
                local interval = os.time() - nets[name].time
                nets[name].time = os.time()

                local down = (recv - nets[name][1])/interval
                local up   = (send - nets[name][2])/interval

                uformat(args, name .. " down", down)
                uformat(args, name .. " up", up)
            end

            -- Store totals
            nets[name][1] = recv
            nets[name][2] = send
        end
    end
    f:close()

    return args
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
