---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2017, 0x5b <dragen15051@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local setmetatable = setmetatable
local pcall = pcall
local helpers = require("vicious.helpers")
local spawn = require("awful.spawn")

local success, json = pcall(require, "cjson")
if not success then
  json = require("json")
end

local string = {
    sub = string.sub,
    upper = string.upper,
}
-- }}}


-- Btc: provides current bitcoin price
-- vicious.widgets.btc
local btc_all = {}


-- {{ Bitcoin widget type
function btc_all.async(format, warg, callback)
    -- Default values
    if not warg then warg = "usd" end

    local btc = { ["{price}"] = "N/A" }
    local currency_code = string.upper(warg)
    local url = "https://api.coindesk.com/v1/bpi/currentprice/" .. currency_code .. ".json"
    local cmd = "curl "..helpers.shellquote(url)

    -- {{ Checking response
    local function parse(response)
        -- If 'response' is not json, 'json.decode' will return Error
        local status, data = pcall(function() return json.decode(response) end)
        if not status or not data then
            return btc
        end

        btc["{price}"] = string.sub(data["bpi"][currency_code]["rate"], 0, -3)
        return btc
    end
    -- }}

    spawn.easy_async(cmd, function(stdout) callback(parse(stdout)) end)
end
-- }}}

return btc_all
