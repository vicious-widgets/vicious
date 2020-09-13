.. _custom-wtype:

Custom Widget Types
===================

Use any of the existing widget types as a starting point for your own.
Write a quick worker function that does the work and plug it in.
How data will be formatted, will it be red or blue, should be
defined in ``rc.lua`` (or somewhere else, outside the actual module).

Before writing a widget type you should check if there is already one
in the contrib directory of Vicious.  The contrib directory contains
extra widgets you can use.  Some are for less common hardware, and others
were contributed by Vicious users.  Most of the contrib widgets are obsolete.
Contrib widgets will not be imported by init unless you explicitly enable it,
or load them in your ``rc.lua``.

Some users would like to avoid writing new modules.  For them Vicious kept
the old Wicked functionality, possibility to register their own functions
as widget types.  By providing them as the second argument to
:lua:func:`vicious.register`.  Your function can accept ``format`` and ``warg``
arguments, just like workers.
