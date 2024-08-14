Usage Examples
==============

Start with a simple widget, like ``date``, then build your setup from there,
one widget at a time.  Also remember that besides creating and registering
widgets you have to add them to a ``wibox`` (statusbar) in order to
actually display them.

Date Widget
-----------

Update every 2 seconds (the default interval),
use standard date sequences as the format string:

.. code-block:: lua

   datewidget = wibox.widget.textbox()
   vicious.register(datewidget, vicious.widgets.date, "%b %d, %R")

Memory Widget
-------------

Update every 13 seconds, append ``MiB`` to 2nd and 3rd returned values
and enables caching.

.. code-block:: lua

   memwidget = wibox.widget.textbox()
   vicious.cache(vicious.widgets.mem)
   vicious.register(memwidget, vicious.widgets.mem, "$1 ($2MiB/$3MiB)", 13)

HDD Temperature Widget
----------------------

Update every 19 seconds, request the temperature level of ``/dev/sda`` and
append *°C* to the returned value.  Since the listening port is not provided,
default one is used.

.. code-block:: lua

   hddtempwidget = wibox.widget.textbox()
   vicious.register(hddtempwidget, vicious.widgets.hddtemp, "${/dev/sda} °C", 19)

Mbox Widget
-----------

Updated every 5 seconds, provide full path to the mbox as argument:

.. code-block:: lua

   mboxwidget = wibox.widget.textbox()
   vicious.register(mboxwidget, vicious.widgets.mbox, "$1", 5,
                    "/home/user/mail/Inbox")

Battery Widget
--------------

Update every 61 seconds, request the current battery charge level
and displays a progressbar, provides ``BAT0`` as battery ID:

.. code-block:: lua

   batwidget = wibox.widget.progressbar()

   -- Create wibox with batwidget
   batbox = wibox.container.margin(
       wibox.widget{ { max_value = 1, widget = batwidget,
                       border_width = 0.5, border_color = "#000000",
                       color = { type = "linear",
                                 from = { 0, 0 },
                                 to = { 0, 30 },
                                 stops = { { 0, "#AECF96" },
                                           { 1, "#FF5656" } } } },
                     forced_height = 10, forced_width = 8,
                     direction = 'east', color = beautiful.fg_widget,
                     layout = wibox.container.rotate },
       1, 1, 3, 3)

   -- Register battery widget
   vicious.register(batwidget, vicious.widgets.bat, "$2", 61, "BAT0")

CPU Usage Widget
----------------

Update every 3 seconds, feed the graph with total usage percentage
of all CPUs/cores:

.. code-block:: lua

   cpuwidget = awful.widget.graph()
   cpuwidget:set_width(50)
   cpuwidget:set_background_color"#494B4F"
   cpuwidget:set_color{ type = "linear", from = { 0, 0 }, to = { 50, 0 },
                        stops = { { 0, "#FF5656" },
                                  { 0.5, "#88A175" },
                                  { 1, "#AECF96" } } }
   vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 3)
