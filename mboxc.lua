---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2009, Adrian C. <anrxc.sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local io = { open = io.open }
local setmetatable = setmetatable
local string = { find = string.find }
-- }}}


-- Mboxc: provides the count of total, old and new messages in a mbox
module("vicious.mboxc")


-- {{{ Mbox count widget type
local function worker(format, mbox)
    -- Initialise counters
    local old = 0
    local total = 0

    -- Open the mbox
    local f = io.open(mbox)

    while true do
      -- Read the mbox line by line, if we are going to read some
      -- *HUGE* folders then switch to reading chunks
      local lines = f:read("*line")
      if not lines then break end

      -- Find all messages
      --  * http://www.jwz.org/doc/content-length.html
      local _, from = string.find(lines, "^From[%s]")
      if from ~= nil then total = total + 1 end

      -- Read messages have the Status header
      local _, status = string.find(lines, "^Status:[%s]RO$")
      if status ~= nil then old = old + 1 end

      -- Skip the folder internal data
      local _, intdata = string.find(lines, "^Subject:[%s].*FOLDER[%s]INTERNAL[%s]DATA")
      if intdata ~= nil then total = total -1 end
    end
    f:close()

    -- Substract total from old to get the new count
    local new = total - old

    return {total, old, new}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })
