----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

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
    local f = io.open(mbox)
    -- mbox could be huge, get a 15kb chunk from EOF
    --  * attachments could be much bigger than this
    f:seek("end", -15360)

    local text = f:read("*all")
    f:close()

    for match in string.gfind(text, "Subject: ([^\n]*)") do
        subject = match
    end

    if subject then
        -- Spam sanitize only the last subject
        subject = helpers.escape(subject)

        -- Don't abuse the wibox, truncate
        subject = helpers.truncate(subject, 22)

        return {subject}
    end
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
