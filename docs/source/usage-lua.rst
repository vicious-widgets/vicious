Usage as a Lua Library
======================

When provided by an operating system package, or installed from source
into the Lua library path, Vicious can be used as a regular Lua_ library,
to be used stand-alone or to feed widgets of any window manager
(e.g. Ion, WMII).  It is compatible with Lua 5.1 and above.

.. code-block:: lua

   > widgets = require("vicious.widgets.init")
   > print(widgets.volume(nil, "Master")[1])
   100

.. _Lua: https://www.lua.org/
