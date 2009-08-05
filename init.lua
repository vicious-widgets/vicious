----------------------------------------------------------------
-- Vicious widgets for the awesome window manager
--
-- Licensed under the GNU General Public License version 2
--   * Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>
--
-- To view a human-readable summary of the license, visit:
--   * http://creativecommons.org/licenses/GPL/2.0/
----------------------------------------------------------------
-- Derived from Wicked, by Lucas de Vries <lucas_glacicle_com>
--   * Wicked is licensed under the WTFPL v2
----------------------------------------------------------------

-- {{{ Grab environment
require("awful")
require("vicious.helpers")

local type = type
local pairs = pairs
local awful = awful
local tonumber = tonumber
local os = { time = os.time }
local table = {
    insert = table.insert,
    remove = table.remove
}

-- Grab C API
local capi = {
    hooks = hooks,
    widget = widget,
    awesome = awesome,
}
-- }}}


-- {{{ Configure widgets
require("vicious.cpu")
require("vicious.cpufreq")
require("vicious.thermal")
require("vicious.load")
require("vicious.uptime")
require("vicious.bat")
require("vicious.batat")
require("vicious.mem")
require("vicious.fs")
require("vicious.dio")
require("vicious.net")
require("vicious.wifi")
require("vicious.mbox")
require("vicious.mboxc")
require("vicious.mdir")
require("vicious.entropy")
require("vicious.org")
require("vicious.pacman")
require("vicious.mpd")
require("vicious.volume")
require("vicious.weather")
require("vicious.date")
-- }}}

-- Vicious: widgets for the awesome window manager
module("vicious")


-- {{{ Initialise variables
local registered   = {}
local widget_cache = {}

-- Initialise the function table
widgets = {}
-- }}}

-- {{{ Widget types
for w, i in pairs(_M) do
    -- Ensure we don't call ourselves
    if i and i ~= _M and type(i) == "table" then
        -- Ignore the function table and helpers
        if w ~= "widgets" and w ~= "helpers" then
            -- Place widgets in the namespace table
            widgets[w] = i
            -- Enable caching for all widget types
            widget_cache[i] = {}
        end
    end
end
-- }}}

-- {{{ Main functions
-- {{{ Register widget
function register(widget, wtype, format, timer, field, warg)
    local reg = {}
    local widget = widget

    -- Set properties
    reg.type   = wtype
    reg.format = format
    reg.timer  = timer
    reg.field  = field
    reg.warg   = warg
    reg.widget = widget

    -- Update function
    reg.update = function ()
        update(widget, reg)
    end

    -- Default to 1s timer
    if reg.timer == nil then
        reg.timer = 1
    end

    -- Register reg object
    regregister(reg)

    -- Return reg object for reuse
    return reg
end
-- }}}

-- {{{ Register from reg object
function regregister(reg)
    if not reg.running then
        -- Put widget in table
        if registered[reg.widget] == nil then
            registered[reg.widget] = {}
            table.insert(registered[reg.widget], reg)
        else
            already = false

            for w, i in pairs(registered) do
                if w == reg.widget then
                    for k, v in pairs(i) do
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

        -- Start timer
        if reg.timer > 0 then
            awful.hooks.timer.register(reg.timer, reg.update)
        end

        -- Initial update
        reg.update()

        -- Set running
        reg.running = true
    end
end
-- }}}

-- {{{ Unregister widget
function unregister(widget, keep, reg)
    if reg == nil then
        for w, i in pairs(registered) do
            if w == widget then
                for k, v in pairs(i) do
                    reg = unregister(w, keep, v)
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

    awful.hooks.timer.unregister(reg.update)
    reg.running = false

    return reg
end
-- }}}

-- {{{ Suspend vicious, halt all widget updates
function suspend()
    for w, i in pairs(registered) do
        for k, v in pairs(i) do
            unregister(w, true, v)
        end
    end
end
-- }}}

-- {{{ Activate vicious, restart all widget updates
function activate(widget)
    for w, i in pairs(registered) do
        if widget == nil or w == widget then
            for k, v in pairs(i) do
                regregister(v)
            end
        end
    end
end
-- }}}

-- {{{ Update widget
function update(widget, reg, disablecache)
    -- Check if there are any equal widgets
    if reg == nil then
        for w, i in pairs(registered) do
            if w == widget then
                for k, v in pairs(i) do
                    update(w, v, disablecache)
                end
            end
        end

        return
    end

    local t = os.time()
    local data = {}

    -- Check if we have output chached for this widget newer than last
    -- widget update
    if widget_cache[reg.type] ~= nil then
        local c = widget_cache[reg.type]

        if c.time == nil or c.time <= t - reg.timer or disablecache then
            c.time = t
            c.data = reg.type(reg.format, reg.warg)
        end
        
        data = c.data
    else
        data = reg.type(reg.format, reg.warg)
    end

    if type(data) == "table" then
        if type(reg.format) == "string" then
            data = helpers.format(reg.format, data)
        elseif type(reg.format) == "function" then
            data = reg.format(widget, data)
        end
    end
    
    if reg.field == nil then
        widget.text = data
    elseif widget.plot_data_add ~= nil then
        widget:plot_data_add(reg.field, tonumber(data))
    elseif widget.bar_data_add ~= nil then
        widget:bar_data_add(reg.field, tonumber(data))
    end

    return data
end
-- }}}
-- }}}
