# Vicious

Vicious is a modular widget library for window managers, but mostly
catering to users of the *awesome* window manager. It was derived from
the old *Wicked* widget library, and has some of the old *Wicked* widget
types, a few of them rewritten, and a good number of new ones.

Vicious widget types are a framework for creating your own
widgets. Vicious contains modules that gather data about your system,
and a few *awesome* helper functions that make it easier to register
timers, suspend widgets and so on. Vicious doesn't depend on any third party
Lua libraries, but may depend on additional system utilities (see widget
description).


## Usage examples

Start with a simple widget, like `date`. Then build your setup from
there, one widget at a time. Also remember that besides creating and
registering widgets you have to add them to a `wibox` (statusbar) in
order to actually display them.

### Date widget

Update every 2 seconds (the default interval), use standard date sequences as
the format string:

```lua
datewidget = wibox.widget.textbox()
vicious.register(datewidget, vicious.widgets.date, "%b %d, %R")
```

### Memory widget

Update every 13 seconds, append `MiB` to 2nd and 3rd returned values and
enables caching.

```lua
memwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.mem)
vicious.register(memwidget, vicious.widgets.mem, "$1 ($2MiB/$3MiB)", 13)
```

### HDD temperature widget

Update every 19 seconds, request the temperature level of the /dev/sda and
append *°C* to the returned value. Since the listening port is not provided,
default one is used.

```lua
hddtempwidget = wibox.widget.textbox()
vicious.register(hddtempwidget, vicious.widgets.hddtemp, "${/dev/sda} °C", 19)
```

### Mbox widget

Updated every 5 seconds, provide full path to the mbox as argument:

```lua
mboxwidget = wibox.widget.textbox()
vicious.register(mboxwidget, vicious.widgets.mbox, "$1", 5,
                 "/home/user/mail/Inbox")
```

### Battery widget

Update every 61 seconds, request the current battery charge level and displays
a progressbar, provides `"BAT0"` as battery ID:

```lua
batwidget = wibox.widget.progressbar()

-- Create wibox with batwidget
batbox = wibox.layout.margin(
    wibox.widget{{max_value = 1, widget = batwidget,
                  border_width = 0.5, border_color = "#000000",
                  color = {type = "linear",
                           from = {0, 0},
                           to = {0, 30},
                           stops = {{0, "#AECF96"}, {1, "#FF5656"}}}},
                 forced_height = 10, forced_width = 8,
                 direction = 'east', color = beautiful.fg_widget,
                 layout = wibox.container.rotate},
    1, 1, 3, 3)

-- Register battery widget
vicious.register(batwidget, vicious.widgets.bat, "$2", 61, "BAT0")
```

### CPU usage widget

Update every 3 seconds, feed the graph with total usage percentage of all
CPUs/cores:

```lua
cpuwidget = awful.widget.graph()
cpuwidget:set_width(50)
cpuwidget:set_background_color"#494B4F"
cpuwidget:set_color{type = "linear", from = {0, 0}, to = {50, 0},
                    stops = {{0, "#FF5656"}, {0.5, "#88A175"}, {1, "#AECF96"}}}
vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 3)
```


## <a name="format-func"></a>Format functions

You can use a function instead of a string as the format parameter.
Then you are able to check the value returned by the widget type and
change it or perform some action. You can change the color of the
battery widget when it goes below a certain point, hide widgets when
they return a certain value or maybe use `string.format` for padding.

Do not confuse this with just coloring the widget, in those cases standard
Pango markup can be inserted into the format string.

The format function will get the widget as its first argument, table
with the values otherwise inserted into the format string as its
second argument, and will return the text/data to be used for the
widget.

### Examples

#### Hide mpd widget when no song is playing

```lua
mpdwidget = wibox.widget.textbox()
vicious.register(
    mpdwidget,
    vicious.widgets.mpd,
    function (widget, args)
        if args["{state}"] == "Stop" then
            return ''
        else
            return ('<span color="white">MPD:</span> %s - %s'):format(
                args["{Artist}"], args["{Title}"])
        end
    end)
```

#### Use string.format for padding

```lua
uptimewidget = wibox.widget.textbox()
vicious.register(uptimewidget, vicious.widgets.uptime,
                 function (widget, args)
                     return ("Uptime: %02d %02d:%02d "):format(
                         args[1], args[2], args[3])
                 end, 61)
```

When it comes to padding it is also useful to mention how a widget can be
configured to have a fixed width. You can set a fixed width on your textbox
widgets by changing their `width` field (by default width is automatically
adapted to text width). The following code forces a fixed width of 50 px to the
uptime widget, and aligns its text to the right:

```lua
uptimewidget = wibox.widget.textbox()
uptimewidget.width, uptimewidget.align = 50, "right"
vicious.register(uptimewidget, vicious.widgets.uptime, "$1 $2:$3", 61)
```

#### Stacked graph

Stacked graphs are handled specially by Vicious: `format` functions passed to
the corresponding widget types must return an array instead of a string.

```lua
cpugraph = wibox.widget.graph()
cpugraph:set_stack(true)
cpugraph:set_stack_colors({"red", "yellow", "green", "blue"})
vicious.register(cpugraph, vicious.widgets.cpu,
                 function (widget, args)
                     return {args[2], args[3], args[4], args[5]}
                 end, 3)
```

The snipet above enables graph stacking/multigraph and plots usage of all four
CPU cores on a single graph.

#### Substitute widget types' symbols

If you are not happy with default symbols used in volume, battery, cpufreq and
other widget types, use your own symbols without any need to modify modules.
The following example uses a custom table map to modify symbols representing
the mixer state: on or off/mute.

```lua
volumewidget = wibox.widget.textbox()
vicious.register(volumewidget, vicious.widgets.volume,
                 function (widget, args)
                     local label = {["♫"] = "O", ["♩"] = "M"}
                     return ("Volume: %d%% State: %s"):format(
                         args[1], label[args[2]])
                 end, 2, "PCM")
```

#### <a name="call-example"></a>Get data from the widget

`vicious.call` could be useful for naughty notification and scripts:

```lua
mybattery = wibox.widget.textbox()
vicious.register(mybattery, vicious.widgets.bat, "$2%", 17, "0")
mybattery:buttons(awful.util.table.join(
    awful.button(
        {}, 1,
        function ()
            naughty.notify{title = "Battery indicator",
                           text = vicious.call(vicious.widgets.bat,
                                               "Remaining time: $3", "0")}
        end)))
```

Format functions can be used as well:

```lua
mybattery:buttons(awful.util.table.join(
    awful.button(
        {}, 1,
        function ()
            naughty.notify{
                title = "Battery indicator",
                text = vicious.call(
                    vicious.widgets.bat,
                    function (widget, args)
                        return ("%s: %10sh\n%s: %14d%%\n%s: %12dW"):format(
                            "Remaining time", args[3],
                            "Wear level", args[4],
                            "Present rate", args[5])
                    end, "0")}
        end)))
```


## Contributing

For details, see CONTRIBUTING.md.  Vicious is licensed under GNU GPLv2+,
which require all code within the package to be released under
a compatible license.  All contributors retain their copyright to their code,
so please make sure you add your name to the header of every file you touch.


## Copying

Vicious is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 2 of the
License, or (at your option) any later version.

Please refer to our documentation for the full [list of authors].


[list of authors]: https://vicious.rtfd.io/copying.html
