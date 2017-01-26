-- {{{ Grab environment
local tonumber = tonumber
local os = { time = os.time }
local setmetatable = setmetatable
local helpers = require("vicious.helpers")
local io = { popen = io.popen }
local string = { match = string.match }
-- }}}


-- Net: provides state and usage statistics of all network interfaces
-- vicious.widgets.net
local net_freebsd = {}


-- Initialize function tables
local nets = {}
-- Variable definitions
local unit = { ["b"] = 1, ["kb"] = 1024,
    ["mb"] = 1024^2, ["gb"] = 1024^3
}

-- {{{ Net widget type
local function worker(format, warg)
    if not warg then return end

    local args = {}
    local buffer = nil
    local f = io.popen("netstat -n -b -I " .. helpers.shellquote(warg))
    local now = os.time()
    
    for line in f:lines() do
        if not (line:find("<Link") or line:find("Name")) then -- skipping missleading lines
            local split = { line:match(("([^%s]*)%s*"):rep(12)) }

            if buffer == nil then
                buffer = { tonumber(split[8]), tonumber(split[11]) } -- recv (field 8) and send (field 11)
            else
                buffer = { buffer[1] + tonumber(split[8]), buffer[2] + tonumber(split[11]) }
            end
        end
    end

    f:close()

    if buffer == nil then
        args["{carrier}"] = 0
        helpers.uformat(args, "rx", 0, unit)
        helpers.uformat(args, "tx", 0, unit)
        helpers.uformat(args, "down", 0, unit)
        helpers.uformat(args, "up",   0, unit)
    else
        args["{carrier}"] = 1
        helpers.uformat(args, "rx", buffer[1], unit)
        helpers.uformat(args, "tx", buffer[2], unit)

        if next(nets) == nil then
            helpers.uformat(args, "down", 0, unit)
            helpers.uformat(args, "up",   0, unit)
        else
            local interval = now - nets["time"]
            if interval <= 0 then interval = 1 end

            local down = (buffer[1] - nets[1]) / interval
            local up   = (buffer[2] - nets[2]) / interval

            helpers.uformat(args, "down", down, unit)
            helpers.uformat(args, "up",   up,   unit)
        end
        
        nets["time"] = now

        -- Store totals
        nets[1] = buffer[1]
        nets[2] = buffer[2]
    end

    return args

end
-- }}}

return setmetatable(net_freebsd, { __call = function(_, ...) return worker(...) end })
