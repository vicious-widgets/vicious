---------------------------------------------------
-- Vicious widgets for the awesome window manager
---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) 2009, Lucas de Vries <lucas@glacicle.com>
---------------------------------------------------

-- {{{ Setup environment
local type  = type
local pairs = pairs
local tonumber = tonumber
local capi  = { timer = timer }
local os    = { time = os.time }
local table = {
    insert  = table.insert,
    remove  = table.remove
}

local helpers = require("vicious.helpers")

-- Vicious: widgets for the awesome window manager
local vicious = {}
vicious.widgets = require("vicious.widgets")
--vicious.contrib = require("vicious.contrib")

-- Initialize tables
local timers       = {}
local registered   = {}
local widget_cache = {}
-- }}}


-- {{{ Local functions
-- {{{ Update a widget
local function update(widget, reg, disablecache)
    -- Check if there are any equal widgets
    if reg == nil then
        for w, i in pairs(registered) do
            if w == widget then
                for _, r in pairs(i) do
                    update(w, r, disablecache)
                end
            end
        end

        return
    end

    local t = os.time()
    local data = {}

    -- Check for chached output newer than the last update
    if widget_cache[reg.wtype] ~= nil then
        local c = widget_cache[reg.wtype]

        if (c.time == nil or c.time <= t-reg.timer) or disablecache then
            c.time, c.data = t, reg.wtype(reg.format, reg.warg)
        end

        data = c.data
    else
        data = reg.wtype and reg.wtype(reg.format, reg.warg)
    end

    if type(data) == "table" then
        if type(reg.format) == "string" then
            data = helpers.format(reg.format, data)
        elseif type(reg.format) == "function" then
            data = reg.format(widget, data)
        end
    end

    if widget.add_value ~= nil then
        widget:add_value(tonumber(data) and tonumber(data)/100)
    elseif widget.set_value ~= nil then
        widget:set_value(tonumber(data) and tonumber(data)/100)
    elseif widget.set_markup ~= nil then
        widget:set_markup(data)
    else
        widget.text = data
    end

    return data
end
-- }}}

-- {{{ Register from reg object
local function regregister(reg)
    if not reg.running then
        if registered[reg.widget] == nil then
            registered[reg.widget] = {}
            table.insert(registered[reg.widget], reg)
        else
            local already = false

            for w, i in pairs(registered) do
                if w == reg.widget then
                    for _, v in pairs(i) do
                        if v == reg then
                            already = true
                            break
                        end
                    end

                    if already then
                        break
                    end
                end
            end

            if not already then
                table.insert(registered[reg.widget], reg)
            end
        end

        -- Start the timer
        if reg.timer > 0 then
            local tm = timers[reg.timer] and timers[reg.timer].timer
            tm = tm or capi.timer({ timeout = reg.timer })
            if tm.connect_signal then
                tm:connect_signal("timeout", reg.update)
            else
                tm:add_signal("timeout", reg.update)
            end
            if not timers[reg.timer] then
                timers[reg.timer] = { timer = tm, refs = 1 }
            else
                timers[reg.timer].refs = timers[reg.timer].refs + 1
            end
            if not tm.started then
                tm:start()
            end
            -- Initial update
            reg.update()
        end
        reg.running = true
    end
end
-- }}}
-- }}}


-- {{{ Global functions
-- {{{ Register a widget
function vicious.register(widget, wtype, format, timer, warg)
    local widget = widget
    local reg = {
        -- Set properties
        wtype  = wtype,
        format = format,
        timer  = timer,
        warg   = warg,
        widget = widget,
    }
    -- Set functions
    reg.update = function ()
        update(widget, reg)
    end

    -- Default to 2s timer
    if reg.timer == nil then
        reg.timer = 2
    end

    -- Register a reg object
    regregister(reg)

    -- Return a reg object for reuse
    return reg
end
-- }}}

-- {{{ Unregister a widget
function vicious.unregister(widget, keep, reg)
    if reg == nil then
        for w, i in pairs(registered) do
            if w == widget then
                for _, v in pairs(i) do
                    reg = vicious.unregister(w, keep, v)
                end
            end
        end

        return reg
    end

    if not keep then
        for w, i in pairs(registered) do
            if w == widget then
                for k, v in pairs(i) do
                    if v == reg then
                        table.remove(registered[w], k)
                    end
                end
            end
        end
    end

    if not reg.running then
        return reg
    end

    -- Disconnect from timer
    local tm  = timers[reg.timer]
    if tm.timer.disconnect_signal then
        tm.timer:disconnect_signal("timeout", reg.update)
    else
        tm.timer:remove_signal("timeout", reg.update)
    end
    reg.running = false
    -- Stop the timer
    tm.refs = tm.refs - 1
    if tm.refs == 0 and tm.timer.started then
        tm.timer:stop()
    end

    return reg
end
-- }}}

-- {{{ Enable caching of a widget type
function vicious.cache(wtype)
    if wtype ~= nil then
        if widget_cache[wtype] == nil then
            widget_cache[wtype] = {}
        end
    end
end
-- }}}

-- {{{ Force update of widgets
function vicious.force(wtable)
    if type(wtable) == "table" then
        for _, w in pairs(wtable) do
            update(w, nil, true)
        end
    end
end
-- }}}

-- {{{ Suspend all widgets
function vicious.suspend()
    for w, i in pairs(registered) do
        for _, v in pairs(i) do
            vicious.unregister(w, true, v)
        end
    end
end
-- }}}

-- {{{ Activate a widget
function vicious.activate(widget)
    for w, i in pairs(registered) do
        if widget == nil or w == widget then
            for _, v in pairs(i) do
                regregister(v)
            end
        end
    end
end
-- }}}

return vicious

-- }}}
