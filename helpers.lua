----------------------------------------------------------
-- Licensed under the GNU General Public License version 2
--  * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
----------------------------------------------------------

-- {{{ Grab environment
local pairs = pairs
local string = { gsub = string.gsub }
-- }}}


-- Helpers: provides helper functions for vicious widgets
module("vicious.helpers")


-- {{{ Helper functions
-- {{{ Format a string with args
function format(format, args)
    -- Format a string
    for var, val in pairs(args) do
        format = string.gsub(format, "$" .. var, val)
    end

    return format
end
-- }}}

--{{{ Escape a string
function escape(text)
    local xml_entities = {
        ["\""] = "&quot;",
        ["&"]  = "&amp;",
        ["'"]  = "&apos;",
        ["<"]  = "&lt;",
        [">"]  = "&gt;"
    }

    return text and text:gsub("[\"&'<>]", xml_entities)
end
-- }}}
-- }}}
