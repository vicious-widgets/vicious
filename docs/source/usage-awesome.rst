Usage within Awesome
====================

To use Vicious with Awesome, install the package from your operating system
provider, or download the source code and move it to your awesome
configuration directory in ``$XDG_CONFIG_HOME`` (usually ``~/.config``)::

   git clone https://github.com/vicious-widgets/vicious.git
   mv vicious $XDG_CONFIG_HOME/awesome/

Vicious will only load modules for widget types you intend to use in
your awesome configuration, to avoid having useless modules sitting in
your memory.

Then add the following to the top of your ``rc.lua``:

.. code-block:: lua

   local vicious = require("vicious")

Register a Widget
-----------------

Once you create a widget (a textbox, graph or a progressbar) call
``vicious.register()`` to register it with Vicious::

   vicious.register(widget, wtype, format, interval, warg)

``widget``
   Awesome_ widget created with ``widget()`` or ``awful.widget()``
   (in case of a graph or a progressbar).

``wtype`` of type Vicious widget or ``function``
   * Vicious widget type: any of the available (default, or custom)
     [widget type provided by Vicious](#widgets).
   * function: custom function from your own *Awesome* configuration can be
     registered as widget types (see [Custom widget types](#custom-widget)).

``format`` of type ``string`` or ``function``
   * string: ``$key`` will be replaced by respective value in the table ``t``
     returned by the widget type. I.e. use ``$1``, ``$2``, etc. to retrieve data
     from an integer-indexed table (a.k.a. array); ``${foo bar}`` will be
     substituted by ``t["{foo bar}"]``.
   * ``function (widget, args)`` can be used to manipulate data returned by the
     widget type (see [Format functions](#format-func)).

``interval``
   Number of seconds between updates of the widget (default: 2).
   Read section :ref:`caching` for more information.

``warg``
   Arguments to be passed to widget types, e.g. the battery ID.

``vicious.register`` alone is not much different from awful.widget.watch_,
which has been added to Awesome since version 4.0.  However, Vicious offers
more advanced control of widgets' behavior by providing the following functions.

Unregister a Widget
-------------------

::

   vicious.unregister(widget, keep)

If ``keep == true``, ``widget`` will be suspended and wait for activation.

Suspend All Widgets
-------------------

::

   vicious.suspend()

See `example automation script`_ for the "laptop-mode-tools" start-stop module.

Restart Suspended Widgets
-------------------------

::

   vicious.activate(widget)

If ``widget`` is provided only that widget will be activated.

Enable Caching of a Widget Type
-------------------------------

::

   vicious.cache(wtype)

Enable caching of values returned by a widget type.

Force update of widgets
-----------------------

::

   vicious.force(wtable)

where ``wtable`` is a table of one or more widgets to be updated.

Get Data from a Widget
----------------------

::

   vicious.call(wtype, format, warg)

Fetch data from ``wtype`` to use it outside from the wibox
([example](#call-example)).

.. _Awesome: https://awesomewm.org/
.. _awful.widget.watch:
   https://awesomewm.org/doc/api/classes/awful.widget.watch.html
.. _example automation script:
   http://sysphere.org/~anrxc/local/sources/lmt-vicious.sh
