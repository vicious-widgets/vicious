---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Henning Glawe <glaweh@debian.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Grab environment
local pairs = pairs
local tonumber = tonumber
local os = { time = os.time }
local io = { lines = io.lines }
local setmetatable = setmetatable
local string = { match = string.match }
local helpers = require("vicious.helpers")
-- }}}


-- Net: provides usage statistics for all network interfaces
-- vicious.contrib.net
local net = {}


-- Initialise function tables
local nets = {}
-- Variable definitions
local unit = { ["b"] = 1, ["kb"] = 1024,
    ["mb"] = 1024^2, ["gb"] = 1024^3
}

-- {{{ Net widget type
local function worker(format, tignorelist)
    local args    = {}
    local tignore = {}
    local total_rx = 0
    local total_tx = 0
    local any_up   = 0

    if not tignorelist then
        tignorelist = {"lo", "wmaster0"}
    end
    for k, i in pairs(tignorelist) do
        tignore[i] = true
    end

    -- Get NET stats
    for line in io.lines("/proc/net/dev") do
        -- Match wmaster0 as well as rt0 (multiple leading spaces)
        local name = string.match(line, "^[%s]?[%s]?[%s]?[%s]?([%w]+):")
        if name ~= nil then
            -- Received bytes, first value after the name
            local recv = tonumber(string.match(line, ":[%s]*([%d]+)"))
            -- Transmited bytes, 7 fields from end of the line
            local send = tonumber(string.match(line,
             "([%d]+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d$"))

            if not tignore[name] then
                total_rx = total_rx + recv
                total_tx = total_tx + send
            end

            helpers.uformat(args, name .. " rx", recv, unit)
            helpers.uformat(args, name .. " tx", send, unit)

            if nets[name] == nil then
                -- Default values on the first run
                nets[name] = {}

                helpers.uformat(args, name .. " down", 0, unit)
                helpers.uformat(args, name .. " up",   0, unit)
                args["{"..name.." carrier}"] = 0

                nets[name].time = os.time()
            else -- Net stats are absolute, substract our last reading
                local interval  = os.time() - nets[name].time >  0 and
                                  os.time() - nets[name].time or 1
                nets[name].time = os.time()

                local down = (recv - nets[name][1]) / interval
                local up   = (send - nets[name][2]) / interval

                helpers.uformat(args, name .. " down", down, unit)
                helpers.uformat(args, name .. " up",   up,   unit)

                -- Carrier detection
                sysnet = helpers.pathtotable("/sys/class/net/" .. name)

                if sysnet.carrier then
                    ccarrier = tonumber(sysnet.carrier)

                    args["{"..name.." carrier}"] = ccarrier
                    if ccarrier ~= 0 and not tignore[name] then
                        any_up = 1
                    end
                else
                    args["{"..name.." carrier}"] = 0
                end
            end

            -- Store totals
            nets[name][1] = recv
            nets[name][2] = send
        end
    end

    helpers.uformat(args, "total rx", total_rx, unit)
    helpers.uformat(args, "total tx", total_tx, unit)

    if nets["total"] == nil then
        -- Default values on the first run
        nets["total"] = {}

        helpers.uformat(args, "total down", 0, unit)
        helpers.uformat(args, "total up",   0, unit)
        args["{total carrier}"] =   0

        nets["total"].time = os.time()
    else -- Net stats are absolute, substract our last reading
        local interval = os.time() - nets["total"].time >  0 and
                         os.time() - nets["total"].time or 1
        nets["total"].time = os.time()

        local down = (total_rx - nets["total"][1]) / interval
        local up   = (total_tx - nets["total"][2]) / interval

        helpers.uformat(args, "total down", down, unit)
        helpers.uformat(args, "total up",   up,   unit)
        args["{total carrier}"] = any_up
    end

    -- Store totals
    nets["total"][1] = total_rx
    nets["total"][2] = total_tx

    return args
end
-- }}}

return setmetatable(net, { __call = function(_, ...) return worker(...) end })
