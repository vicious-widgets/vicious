-- contrib/btc_all.lua
-- Copyright (C) 2017  0x5b <dragen15051@gmail.com>
-- Copyright (C) 2017  Joerg Thalheim <joerg@thalheim.io>
-- Copyright (C) 2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
--
-- This file is part of Vicious.
--
-- Vicious is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as
-- published by the Free Software Foundation, either version 2 of the
-- License, or (at your option) any later version.
--
-- Vicious is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Vicious.  If not, see <https://www.gnu.org/licenses/>.

-- {{{ Grab environment
local pcall = pcall
local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")

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

return helpers.setasyncall(btc_all)
