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
module("vicious.mbox")


-- {{{ Mailbox widget type
local function worker(format, warg)
    if type(warg) ~= "table" then mbox = warg end
    -- mbox could be huge, get a 30kb chunk from EOF
    --  * attachments could be much bigger than this
    local f = io.open(mbox or warg[1])
    f:seek("end", -30720)
    local txt = f:read("*all")
    f:close()

    -- Default value
    local subject = "N/A"

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

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
