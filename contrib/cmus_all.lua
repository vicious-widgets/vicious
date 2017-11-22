-----------------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2017, JuanKman94 <juan.carlos.menonita@gmail.com>
-----------------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local io = { popen = io.popen }
local setmetatable = setmetatable
local string = { gmatch = string.gmatch, format = string.format }
local helpers = require("vicious.helpers")
-- }}}


-- Cmus: provides CMUS information
-- vicious.widgets.cmus
local cmus_all = {}


-- {{{ CMUS widget type
local function worker(format, warg)
    local cmus_state  = {
        ["{duration}"]  = 0,
        ["{file}"] = "N/A",
        ["{status}"] = "N/A",
        ["{title}"]  = "N/A",
        ["{artist}"]  = "N/A",
        ["{continue}"]  = false,
        ["{shuffle}"]  = false,
        ["{repeat}"]  = false,
    }

    -- Fallback to CMUS defaults
    local host = warg and (warg.host or warg[1]) or os.getenv("CMUS_SOCKET")

    if not host and os.getenv("XDG_RUNTIME_DIR") then
        host = os.getenv("XDG_RUNTIME_DIR") .. "/cmus-socket"
    elseif not host then
        host = os.getenv("HOME") .. "/.config/cmus/socket"
    end

    -- Get data from CMUS server
    local f = io.popen(string.format("cmus-remote --query --server %s", host))

    for line in f:lines() do
        for module, value in string.gmatch(line, "([%w]+) (.*)$") do
            if module == "file" then
                cmus_state["{"..module.."}"] = helpers.escape(value)
            elseif module == "duration" then
                cmus_state["{"..module.."}"] = tonumber(value)
            elseif module == "status" then
                cmus_state["{"..module.."}"] = value
            else
                for k, v in string.gmatch(value, "([%w]+) (.*)$") do
                    if module == "tag" then
                        if k == "title" or k == "artist" then
							cmus_state["{"..k.."}"] = helpers.escape(v)
                        end
                    elseif module == "set" then
                        if k == "continue" or k == "shuffle" or k == "repeat" then
							cmus_state["{"..k.."}"] = v == "true"
                        end
                    end
                end
            end
        end
    end
    f:close()

    return cmus_state
end
-- }}}

return setmetatable(cmus_all, { __call = function(_, ...) return worker(...) end })
