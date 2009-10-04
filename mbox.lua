---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
local string = { gfind = string.gfind }
local helpers = require("vicious.helpers")
-- }}}


-- Mbox: provides the subject of last e-mail in a mbox file
module("vicious.mbox")


-- {{{ Mailbox widget type
local function worker(format, mbox)
    -- mbox could be huge, get a 30kb chunk from EOF
    --  * attachments could be much bigger than this
    local f = io.open(mbox)
    f:seek("end", -30720)
    local txt = f:read("*all")
    f:close()

    -- Default value
    local subject = "N/A"

    -- Find all Subject lines
    for i in string.gfind(txt, "Subject: ([^\n]*)") do
       subject = i
    end

    -- Spam sanitize only the last subject
    subject = helpers.escape(subject)

    -- Don't abuse the wibox, truncate
    subject = helpers.truncate(subject, 22)

    return {subject}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
