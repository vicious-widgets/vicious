---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local los = { getenv = os.getenv }
local string = { match = string.match }
local helpers = require("vicious.helpers")
local spawn = require("vicious.spawn")
-- }}}


-- OS: provides operating system information
-- vicious.widgets.os
local os_bsd = {}


-- {{{ Operating system widget type
local function parse(stdout, stderr, exitreason, exitcode)
    local system = {
        ["ostype"]    = "N/A",
        ["hostname"]  = "N/A",
        ["osrelease"] = "N/A",
        ["username"]  = "N/A",
        ["entropy"]   = "N/A",
        ["entropy_p"] = "N/A"
    }

    -- BSD manual page: uname(1)
    system["ostype"], system["hostname"], system["osrelease"] =
        string.match(stdout, "([%w]+)[%s]([%w%p]+)[%s]([%w%p]+)")

    -- Get user from the environment
    system["username"] = los.getenv("USER")

    return {system["ostype"], system["osrelease"], system["username"],
            system["hostname"], system["entropy"], system["entropy_p"]}
end

function os_bsd.async(format, warg, callback)
    spawn.easy_async("uname -snr",
                     function (...) callback(parse(...)) end)
end
-- }}}

return helpers.setasyncall(os_bsd)
