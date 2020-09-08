.. _caching:

Power and Caching
=================

When a lot of widgets are in use they, and awesome, can generate a lot
of wake-ups and also be very expensive for system resources.  This is
especially important when running on battery power.  It was a big problem
with awesome v2 and widgets that used shell scripts to gather data,
and with widget libraries written in languages like Ruby.

Lua is an extremely fast and efficient programming language, and Vicious
takes advantage of that.  But suspending Vicious widgets is one way
to prevent them from draining your battery, despite that.

Update intervals also play a big role, and you can save a lot of power
with a smart approach.  Don't use intervals like: 5, 10, 30, 60, etc.
to avoid harmonics.  If you take the 60-second mark as an example,
all of your widgets would be executed at that point.  Instead think about
using only prime numbers, in that case you will have only a few widgets
executed at any given time interval.  When choosing intervals also consider
what a widget actually does.  Some widget types read files that reside
in memory, others call external utilities and some, like the mbox widget,
read big files.

Vicious can also cache values returned by widget types.  Caching enables you
to have multiple widgets using the same widget type.  With caching its worker
function gets executed only once---which is also great for saving power.

* Some widget types keep internal data and if you call one multiple times
  without caching, the widget that executes it first would modify stored values.
  This can lead to problems and give you inconsistent data.  Remember it
  for widget types like CPU and Network usage, which compare the old set
  of data with the new one to calculate current usage.
* Widget types that require a widget argument to be passed should be
  handled carefully.  If you are requesting information for different devices
  then caching should not be used, because you could get inconsistent data.
