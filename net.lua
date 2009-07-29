----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local os = { time = os.time }
local io = { open = io.open }
local math = { floor = math.floor }
local helpers = require("vicious.helpers")
-- }}}


-- Net: provides usage statistics for all network interfaces
module("vicious.net")


-- Initialise function tables
local nets = {}

-- {{{ Net widget type
function worker(format, padding)
    -- Get /proc/net/dev
    local f = io.open("/proc/net/dev")
    local args = {}

    -- Format data
    for line in f:lines() do
        -- Match wmaster0 as well as rt0 (multiple leading spaces)
        if line:match("^[%s]?[%s]?[%s]?[%s]?[%w]+:") then
            name = line:match("^[%s]?[%s]?[%s]?[%s]?([%w]+):")
            -- Received bytes, first value after the name
            recv = tonumber(line:match(":[%s]*([%d]+)"))
            -- Transmited bytes, 7 fields from end of the line
            send = tonumber(line:match("([%d]+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d$"))

            if padding then
                args["{"..name.." rx}"] = helpers.bytes_to_string(recv, nil, padding)
                args["{"..name.." tx}"] = helpers.bytes_to_string(send, nil, padding)
            else
                args["{"..name.." rx}"] = helpers.bytes_to_string(recv)
                args["{"..name.." tx}"] = helpers.bytes_to_string(send)
            end

            args["{"..name.." rx_b}"]  = math.floor(recv*10)/10
            args["{"..name.." tx_b}"]  = math.floor(send*10)/10
            
            args["{"..name.." rx_kb}"] = math.floor(recv/1024*10)/10
            args["{"..name.." tx_kb}"] = math.floor(send/1024*10)/10

            args["{"..name.." rx_mb}"] = math.floor(recv/1024/1024*10)/10
            args["{"..name.." tx_mb}"] = math.floor(send/1024/1024*10)/10

            args["{"..name.." rx_gb}"] = math.floor(recv/1024/1024/1024*10)/10
            args["{"..name.." tx_gb}"] = math.floor(send/1024/1024/1024*10)/10

            if nets[name] == nil then 
                -- Default values on our first run
                nets[name] = {}
                args["{"..name.." down}"] = "n/a"
                args["{"..name.." up}"] = "n/a"
                
                args["{"..name.." down_b}"] = 0
                args["{"..name.." up_b}"] = 0

                args["{"..name.." down_kb}"] = 0
                args["{"..name.." up_kb}"] = 0

                args["{"..name.." down_mb}"] = 0
                args["{"..name.." up_mb}"] = 0

                args["{"..name.." down_gb}"] = 0
                args["{"..name.." up_gb}"] = 0

                nets[name].time = os.time()
            else
                -- Net stats are absolute, substract our last reading
                interval = os.time() - nets[name].time
                nets[name].time = os.time()

                down = (recv - nets[name][1])/interval
                up   = (send - nets[name][2])/interval

                if padding then
                    args["{"..name.." down}"] = helpers.bytes_to_string(down, true, padding)
                    args["{"..name.." up}"] = helpers.bytes_to_string(up, true, padding)
                else
                    args["{"..name.." down}"] = helpers.bytes_to_string(down, true)
                    args["{"..name.." up}"] = helpers.bytes_to_string(up, true)
                end

                args["{"..name.." down_b}"] = math.floor(down*10)/10
                args["{"..name.." up_b}"] = math.floor(up*10)/10

                args["{"..name.." down_kb}"] = math.floor(down/1024*10)/10
                args["{"..name.." up_kb}"] = math.floor(up/1024*10)/10

                args["{"..name.." down_mb}"] = math.floor(down/1024/1024*10)/10
                args["{"..name.." up_mb}"] = math.floor(up/1024/1024*10)/10

                args["{"..name.." down_gb}"] = math.floor(down/1024/1024/1024*10)/10
                args["{"..name.." up_gb}"] = math.floor(up/1024/1024/1024*10)/10
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
