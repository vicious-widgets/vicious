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
