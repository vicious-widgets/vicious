Welcome to Vicious' documentation!
==================================

Vicious is a modular widget library for window managers, but mostly catering
to users of the `awesome window manager`_.  It was derived from the old
*wicked* widget library, and has some of the old *wicked* widget types,
a few of them rewritten, and a good number of new ones.

Vicious widget types are a framework for creating your own widgets.
Vicious contains modules that gather data about your system,
and a few *awesome* helper functions that make it easier to register timers,
suspend widgets and so on.  Vicious doesn't depend on any third party Lua_
library, but may depend on additional system utilities.

Table of Contents
-----------------

.. toctree::
   :maxdepth: 2

   usage-lua
   usage-awesome
   examples
   widgets
   contrib
   custom
   format
   caching
   security
   contributing
   copying
   changelog

See Also
--------

* Manual pages: `awesome(1)`_, `awesomerc(5)`_
* `Awesome declarative layout system`_
* `My first awesome`_
* `Example awesome configuration`_ (outdated)

.. _awesome window manager: https://awesomewm.org
.. _Lua: https://www.lua.org
.. _awesome(1): https://awesomewm.org/doc/manpages/awesome.1.html
.. _awesomerc(5): https://awesomewm.org/doc/manpages/awesomerc.5.html
.. _Awesome declarative layout system:
   https://awesomewm.org/apidoc/documentation/03-declarative-layout.md.html
.. _My first awesome:
   https://awesomewm.org/doc/api/documentation/07-my-first-awesome.md.html
.. _Example awesome configuration: http://git.sysphere.org/awesome-configs/
