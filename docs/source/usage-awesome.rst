Usage within Awesome
====================

To use Vicious with awesome_, install the package from your operating system
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

vicious.register
----------------

Once you create a widget (a textbox, graph or a progressbar),
call ``vicious.register`` to register it with Vicious:

.. lua:function:: vicious.register(widget, wtype, format, interval, warg)

   Register a widget.

   :param widget: awesome widget created from
                  ``awful.widget`` or ``wibox.widget``

   :param wtype: either of

      * Vicious widget type: any widget type
        :ref:`provided by Vicious <widgets>` or customly defined.
      * ``function``: custom function from your own
        awesome configuration can be registered as widget types
        (see :ref:`custom-wtype`).

   :param format: either of

      * string: ``$key`` will be replaced by respective value in the table
        ``t`` returned by the widget type, i.e. use ``$1``, ``$2``, etc.
        to retrieve data from an integer-indexed table (a.k.a. array);
        ``${foo bar}`` will be substituted by ``t["{foo bar}"]``.
      * ``function (widget, args)`` can be used to manipulate data returned
        by the widget type (see :ref:`format-func`).

   :param interval: number of seconds between updates of the widget
                    (default: 2).  See :ref:`caching` for more information.

   :param warg: arguments to be passed to widget types, e.g. the battery ID.

``vicious.register`` alone is not much different from awful.widget.watch_,
which has been added to Awesome since version 4.0.  However, Vicious offers
more advanced control of widgets' behavior by providing the following functions.

vicious.unregister
------------------

.. lua:function:: vicious.unregister(widget, keep)

   Unregister a widget.

   :param widget: awesome widget created from
                  ``awful.widget`` or ``wibox.widget``
   :param keep: if true suspend ``widget`` and wait for activation
   :type keep: bool

vicious.suspend
---------------

.. lua:function:: vicious.suspend()

   Suspend all widgets.

See `example automation script`_ for the "laptop-mode-tools" start-stop module.

vicious.activate
----------------

.. lua:function:: vicious.activate([widget])

   Restart suspended widget(s).

   :param widget: if provided only that widget will be activated

vicious.cache
-------------

.. lua:function:: vicious.cache(wtype)

   Enable caching of values returned by a widget type.

vicious.force
--------------

.. lua:function:: vicious.force(wtable)

   Force update of given widgets.

   :param wtable: table of one or more widgets to be updated

vicious.call[_async]
--------------------

.. lua:function:: vicious.call(wtype, format, warg)

   Get formatted data from a synchronous widget type
   (:ref:`example <call-example>`).

   :param wtype: either of

      * Vicious widget type: any synchronous widget type
        :ref:`provided by Vicious <widgets>` or customly defined.
      * ``function``: custom function from your own
        awesome configuration can be registered as widget types
        (see :ref:`custom-wtype`).

   :param format: either of

      * string: ``$key`` will be replaced by respective value in the table
        ``t`` returned by the widget type, i.e. use ``$1``, ``$2``, etc.
        to retrieve data from an integer-indexed table (a.k.a. array);
        ``${foo bar}`` will be substituted by ``t["{foo bar}"]``.
      * ``function (widget, args)`` can be used to manipulate data returned
        by the widget type (see :ref:`format-func`).

   :param warg: arguments to be passed to the widget type, e.g. the battery ID.

   :return: ``nil`` if the widget type is asynchronous,
            otherwise the formatted data from with widget type.

.. lua:function:: vicious.call_async(wtype, format, warg, callback)

   Get formatted data from an asynchronous widget type.

   :param wtype: any asynchronous widget type
                 :ref:`provided by Vicious <widgets>` or customly defined.

   :param format: either of

      * string: ``$key`` will be replaced by respective value in the table
        ``t`` returned by the widget type, i.e. use ``$1``, ``$2``, etc.
        to retrieve data from an integer-indexed table (a.k.a. array);
        ``${foo bar}`` will be substituted by ``t["{foo bar}"]``.
      * ``function (widget, args)`` can be used to manipulate data returned
        by the widget type (see :ref:`format-func`).

   :param warg: arguments to be passed to the widget type.

   :param callback: function taking the formatted data from with widget type.
                    If the given widget type happens to be synchronous,
                    ``nil`` will be passed to ``callback``.

.. _awesome: https://awesomewm.org/
.. _awful.widget.watch:
   https://awesomewm.org/doc/api/classes/awful.widget.watch.html
.. _example automation script:
   http://sysphere.org/~anrxc/local/sources/lmt-vicious.sh
