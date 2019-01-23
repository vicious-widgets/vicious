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
local timer = (type(timer) == 'table' and timer or require("gears.timer"))
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

    local update_time = os.time()

    local function format_data(data)
        local ret
        if type(data) == "table" then
            local escaped_data = {}
            for k, v in pairs(data) do
                if type(v) == "string" then
                    escaped_data[k] = helpers.escape(v)
                else
                    escaped_data[k] = v
                end
            end

            if type(reg.format) == "string" then
                ret = helpers.format(reg.format, escaped_data)
            elseif type(reg.format) == "function" then
                ret = reg.format(widget, escaped_data)
            end
        end
        return ret or data
    end

    local function update_value(data)
        local fmtd_data = format_data(data)
        if widget.add_value ~= nil then
            if widget.get_stack ~= nil and widget:get_stack() then
                for idx, _ in ipairs(widget:get_stack_colors()) do
                    if fmtd_data[idx] then
                        widget:add_value(tonumber(fmtd_data[idx]) and tonumber(fmtd_data[idx]/100), idx)
                    end
                end
            else
                widget:add_value(tonumber(fmtd_data) and tonumber(fmtd_data)/100)
            end
        elseif widget.set_value ~= nil then
            widget:set_value(tonumber(fmtd_data) and tonumber(fmtd_data)/100)
        elseif widget.set_markup ~= nil then
            widget:set_markup(fmtd_data)
        else
            widget.text = fmtd_data
        end
    end

    local function update_cache(data, t, cache)
        -- Update cache
        if t and cache then
            cache.time, cache.data = t, data
        end
    end

    -- Check for cached output newer than the last update
    local c = widget_cache[reg.wtype]
    if c and update_time < c.time + reg.timeout and not disablecache then
        update_value(c.data)
    elseif reg.wtype then
        if type(reg.wtype) == "table" and reg.wtype.async then
            if not reg.lock then
                reg.lock = true
                return reg.wtype.async(reg.format,
                    reg.warg,
                    function(data)
                        update_cache(data, update_time, c)
                        update_value(data)
                        reg.lock=false
                    end)
            end
        else
            local data = reg.wtype(reg.format, reg.warg)
            update_cache(data, update_time, c)
            update_value(data)
        end
    end
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
        if reg.timeout > 0 then
            local tm = timers[reg.timeout] and timers[reg.timeout].timer
            tm = tm or timer({ timeout = reg.timeout })
            if tm.connect_signal then
                tm:connect_signal("timeout", reg.update)
            else
                tm:add_signal("timeout", reg.update)
            end
            if not timers[reg.timeout] then
                timers[reg.timeout] = { timer = tm, refs = 1 }
            else
                timers[reg.timeout].refs = timers[reg.timeout].refs + 1
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
function vicious.register(widget, wtype, format, timeout, warg)
    local reg = {
        -- Set properties
        wtype   = wtype,
        lock    = false,
        format  = format,
        timeout = timeout or 2,
        warg    = warg,
        widget  = widget,
    }
    reg.timer = timeout  -- For backward compatibility.

    -- Set functions
    function reg.update()
        update(widget, reg)
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
    local tm  = timers[reg.timeout]
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
            widget_cache[wtype] = { data = nil, time = 0 }
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

-- {{{ Get custom widget format data
function vicious.call(myw, format, warg)
    local mydata = myw(format, warg)
    if type(format) == "string" then
        return helpers.format(format, mydata)
    elseif type(format) == "function" then
        return format(myw, mydata)
    end
end
-- }}}

return vicious

-- }}}
