---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local type = type
local io = { open = io.open }
local setmetatable = setmetatable
local string = { gfind = string.gfind }
local helpers = require("vicious.helpers")
-- }}}


-- Mbox: provides the subject of last e-mail in a mbox file
-- vicious.widgets.mbox
local mbox = {}


-- Initialize variables
local subject = "N/A"

-- {{{ Mailbox widget type
local function worker(format, warg)
    if not warg then return end

    -- mbox could be huge, get a 30kb chunk from EOF
    if type(warg) ~= "table" then _mbox = warg end
    -- * attachment could be much bigger than 30kb
    local f = io.open(_mbox or warg[1])
    f:seek("end", -30720)
    local txt = f:read("*all")
    f:close()

    -- Find all Subject lines
    for i in string.gfind(txt, "Subject: ([^\n]*)") do
       subject = i
    end

    -- Check if we should scroll, or maybe truncate
    if type(warg) == "table" then
        if warg[3] ~= nil then
            subject = helpers.scroll(subject, warg[2], warg[3])
        else
            subject = helpers.truncate(subject, warg[2])
        end
    end

    return {helpers.escape(subject)}
end
-- }}}

return setmetatable(mbox, { __call = function(_, ...) return worker(...) end })
