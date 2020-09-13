.. _format-func:

Format Functions
================

You can use a function instead of a string as the format parameter.
Then you are able to check the value returned by the widget type
and change it or perform some action.  You can change the color of
the battery widget when it goes below a certain point, hide widgets
when they return a certain value or maybe use ``string.format`` for padding.

Do not confuse this with just coloring the widget, in those cases
standard Pango markup can be inserted into the format string.

The format function will get the widget as its first argument, table with
the values otherwise inserted into the format string as its second argument,
and will return the text/data to be used for the widget.

Examples
--------

Hide mpd widget when no song is playing
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: lua

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

Use string.format for padding
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: lua

   uptimewidget = wibox.widget.textbox()
   vicious.register(uptimewidget, vicious.widgets.uptime,
                    function (widget, args)
                        return ("Uptime: %02d %02d:%02d "):format(
                            args[1], args[2], args[3])
                    end, 61)

When it comes to padding it is also useful to mention how a widget
can be configured to have a fixed width.  You can set a fixed width on
your textbox widgets by changing their ``width`` field (by default width
is automatically adapted to text width).  The following code forces
a fixed width of 50 px to the uptime widget, and aligns its text to the right:

.. code-block:: lua

   uptimewidget = wibox.widget.textbox()
   uptimewidget.width, uptimewidget.align = 50, "right"
   vicious.register(uptimewidget, vicious.widgets.uptime, "$1 $2:$3", 61)

Stacked graph
^^^^^^^^^^^^^

Stacked graphs are handled specially by Vicious: ``format`` functions passed
to the corresponding widget types must return an array instead of a string.

.. code-block:: lua

   cpugraph = wibox.widget.graph()
   cpugraph:set_stack(true)
   cpugraph:set_stack_colors{ "red", "yellow", "green", "blue" }
   vicious.register(cpugraph, vicious.widgets.cpu,
                    function (widget, args)
                        return { args[2], args[3], args[4], args[5] }
                    end, 3)

The snipet above enables graph stacking/multigraph and plots usage of all four
CPU cores on a single graph.

Substitute widget types' symbols
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you are not happy with default symbols used in volume, battery, cpufreq and
other widget types, use your own symbols without any need to modify modules.
The following example uses a custom table map to modify symbols representing
the mixer state: on or off/mute.

.. code-block:: lua

   volumewidget = wibox.widget.textbox()
   vicious.register(volumewidget, vicious.widgets.volume,
                    function (widget, args)
                        local label = { ["🔉"] = "O", ["🔈"] = "M" }
                        return ("Volume: %d%% State: %s"):format(
                            args[1], label[args[2]])
                    end, 2, "PCM")

.. _call-example:

Get data from the widget
^^^^^^^^^^^^^^^^^^^^^^^^

:lua:func:`vicious.call` could be useful for naughty notification and scripts:

.. code-block:: lua

   mybattery = wibox.widget.textbox()
   vicious.register(mybattery, vicious.widgets.bat, "$2%", 17, "0")
   mybattery:buttons(awful.util.table.join(awful.button(
       {}, 1,
       function ()
           naughty.notify{ title = "Battery indicator",
                           text = vicious.call(vicious.widgets.bat,
                                               "Remaining time: $3", "0") }
       end)))

Format functions can be used as well:

.. code-block:: lua

   mybattery:buttons(awful.util.table.join(awful.button(
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
                   end, "0") }
       end)))
