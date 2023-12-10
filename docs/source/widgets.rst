.. _widgets:

Officially Supported Widget Types
=================================

Widget types consist of worker functions that take two arguments
``format`` and ``warg`` (in that order), which were previously
passed to :lua:func:`vicious.register`, and return a table of values
to be formatted by ``format``.

vicious.widgets.amdgpu
----------------------

Provides GPU and VRAM usage statistics for AMD graphics cards.

Supported platforms: GNU/Linux (require ``sysfs``)

* ``warg`` (from now on will be called *argument*): card ID, e.g. ``"card0"``
* Returns a table with string keys: ``${gpu_usage}``, ``${mem_usage}``

vicious.widgets.bat
-------------------

Provides state, charge, and remaining time for a requested battery.

Supported platforms: GNU/Linux (require ``sysfs``),
FreeBSD (require ``acpiconf``) and OpenBSD (no extra requirements).

* Argument:

  * On GNU/Linux: battery ID, e.g. ``"BAT0"``
  * On FreeBSD (optional): battery ID, e.g. ``"batt"`` or ``"0"``
  * On OpenBSD (optional): ``bat`` followed by battery index,
    e.g. ``"bat0"`` or ``"bat1"`` on systems with more than one battery

* Returns an array (integer-indexed table) consisting of:

  * ``$1``: State of requested battery
  * ``$2``: Charge level in percent
  * ``$3``: Remaining (charging or discharging) time
  * ``$4``: Wear level in percent
  * ``$5``: Current (dis)charge rate in Watt

vicious.contrib.cmus
--------------------

Provides cmus player information using ``cmus-remote``.

Supported platforms: platform independent.

* Argument: a table whose first field is the socket including host (or nil).
* Returns a table with string keys: ``${status}``, ``${artist}``, ``${title}``,
  ``${duration}``, ``${file}``,  ``${continue}``, ``${shuffle}``, ``${repeat}``.

vicious.widgets.cpu
-------------------

Provides CPU usage for all available CPUs/cores. Since this widget type give
CPU utilization between two consecutive calls, it is recommended to enable
caching if it is used to register multiple widgets (#71).

Supported platforms: GNU/Linux, FreeBSD, OpenBSD.

On FreeBSD and Linux returns an array containing:

* ``$1``: usage of all CPUs/cores
* ``$2``, ``$3``, etc. are respectively the usage of 1st, 2nd, etc. CPU/core

On OpenBSD returns an array containing:

* ``$1``: usage of all CPUs/cores

vicious.widgets.cpufreq
-----------------------

Provides freq, voltage and governor info for a requested CPU.

Supported platforms: GNU/Linux, FreeBSD.

* Argument: CPU ID, e.g. ``"cpu0"`` on GNU/Linux, ``"0"`` on FreeBSD
* Returns an array containing:

  * ``$1``: Frequency in MHz
  * ``$2``: Frequency in GHz
  * ``$3``: Voltage in mV
  * ``$4``: Voltage in V
  * ``$5``: Governor state
  * On FreeBSD: only the first two are supported
    (other values will always be ``"N/A"``)

vicious.widgets.cpuinf
----------------------

Provides speed and cache information for all available CPUs/cores.

Supported platforms: GNU/Linux.

Returns a table whose keys using CPU ID as a base, e.g. ``${cpu0 mhz}``,
``${cpu0 ghz}``, ``${cpu0 kb}``, ``${cpu0 mb}``, ``${cpu1 mhz}``, etc.

vicious.widgets.date
--------------------

Provides access to Lua's ``os.date``, with optional settings for time format
and time offset.

Supported platforms: platform independent.

* ``format`` (optional): a `strftime(3)`_ format specification string
  (format functions are not supported).  If not provided, use the prefered
  representation for the current locale.
* Argument (optional): time offset in seconds, e.g. for different a time zone.
  If not provided, current time is used.
* Returns the output of ``os.date`` formatted by ``format`` *string*.

vicious.widgets.dio
-------------------

Provides I/O statistics for all available storage devices.

Supported platforms: GNU/Linux.

Returns a table with string keys: ``${sda total_s}``, ``${sda total_kb}``,
``${sda total_mb}``, ``${sda read_s}``, ``${sda read_kb}``, ``${sda read_mb}``,
``${sda write_s}``, ``${sda write_kb}``, ``${sda write_mb}``,
``${sda iotime_ms}``, ``${sda iotime_s}``, ``${sdb1 total_s}``, etc.

vicious.widget.fanspeed
-----------------------

Provides fanspeed information for specified fans.

Supported platforms: FreeBSD.

* Argument: full ``sysctl`` string to one or multiple entries,
  e.g.  ``"dev.acpi_ibm.0.fan_speed"``
* Returns speed of specified fan in RPM, ``"N/A"`` on error
  (probably wrong string)

vicious.widgets.fs
------------------

Provides usage of disk space.

Supported platforms: platform independent.

* Argument (optional): if true includes remote filesystems, otherwise fallback
  to default, where only local filesystems are included.
* Returns a table with string keys, using mount points as a base,
  e.g.  ``${/ size_mb}``, ``${/ size_gb}``, ``${/ used_mb}``, ``${/ used_gb}``,
  ``${/ used_p}``, ``${/ avail_mb}``, ``${/ avail_gb}``, ``${/ avail_p}``,
  ``${/home size_mb}``, etc.
  mb and gb refer to mebibyte and gibibyte respectively.

vicious.widgets.gmail
---------------------

Provides count of new and subject of last e-mail on Gmail.

Supported platform: platform independent, requiring ``curl``.

This widget expects login information in your ``~/.netrc`` file, e.g.
``machine mail.google.com login user password pass``. Use your `app
password`_  if you can, or disable `two step verification`_
and `allow access for less secure apps`_.

.. caution::

   Making these settings is a security risk!

* Arguments (optional): either a number or a table

  * If it is a number, subject will be truncated.
  * If it is a table whose first field is the maximum length and second field
    is the widget name (e.g. ``"gmailwidget"``), scrolling will be used.

* Returns a table with string keys: ``${count}`` and ``${subject}``

vicious.widgets.hddtemp
-----------------------

Provides hard drive temperatures using the hddtemp daemon.

Supported platforms: GNU/Linux, requiring ``hddtemp`` and ``curl``.

* Argument (optional): ``hddtemp`` listening port (default: 7634)
* Returns a table with string keys, using hard drives as a base, e.g.
  ``${/dev/sda}`` and ``${/dev/sdc}``.

vicious.widgets.hwmontemp
-------------------------

Provides name-based access to hwmon devices via sysfs.

Supported platforms: GNU/Linux

* Argument: an array with sensor name and input number
  (optional, falling back to ``1``), e.g. ``{"radeon", 2}``
* Returns a table with just the temperature value: ``$1``
* Usage example:

  .. code-block:: lua

     gputemp = wibox.widget.textbox()
     vicious.register(gputemp, vicious.widgets.hwmontemp, " $1°C", 5, {"radeon"})

vicious.widgets.mbox
--------------------

Provides the subject of last e-mail in a mbox file.

Supported platforms: platform independent.

* Argument: either a string or a table:

  * A string representing the full path to the mbox, or
  * Array of the form ``{path, maximum_length[, widget_name]}``.
    If the widget name is provided, scrolling will be used.
  * Note: the path will be escaped so special variables like ``~`` will not
    work, use ``os.getenv`` instead to access environment variables.

* Returns an array whose first value is the subject of the last e-mail.

vicious.widgets.mboxc
---------------------

Provides the count of total, old and new messages in mbox files.

Supported platforms: platform independent.

* Argument: an array full paths to mbox files.
* Returns an array containing:

  * ``$1``: Total number of messages
  * ``$2``: Number of old messages
  * ``$3``: Number of new messages

vicious.widgets.mdir
--------------------

Provides the number of unread messages in Maildir structures/directories.

Supported platforms: platform independent.

* Argument: an array with full paths to Maildir structures.
* Returns an array containing:

  * ``$1``: Number of new messages
  * ``$2``: Number of *old* messages lacking the *Seen* flag

vicious.widgets.mem
-------------------

Provides RAM and Swap usage statistics.

Supported platforms: GNU/Linux, FreeBSD.

Returns (per platform):
* GNU/Linux: an array consisting of:

  * ``$1``: Memory usage in percent
  * ``$2``: Memory usage in MiB
  * ``$3``: Total system memory in MiB
  * ``$4``: Free memory in MiB
  * ``$5``: Swap usage in percent
  * ``$6``: Swap usage in MiB
  * ``$7``: Total system swap in MiB
  * ``$8``: Free swap in MiB
  * ``$9``: Memory usage with buffers and cache, in MiB

* FreeBSD: an array including:

  * ``$1``: Memory usage in percent
  * ``$2``: Memory usage in MiB
  * ``$3``: Total system memory in MiB
  * ``$4``: Free memory in MiB
  * ``$5``: Swap usage in percent
  * ``$6``: Swap usage in MiB
  * ``$7``: Total system swap in MiB
  * ``$8``: Free swap in MiB
  * ``$9``: Wired memory in percent
  * ``$10``: Wired memory in MiB
  * ``$11``: Unfreeable memory (basically active+inactive+wired) in percent
  * ``$12``: Unfreeable memory in MiB

vicious.widgets.mpd
-------------------

Provides Music Player Daemon information.

Supported platforms: platform independent (required tools: ``curl``).

* Argument: an array including password, hostname, port and separator in that
  order, or a table with the previously mentioned fields.
  ``nil`` fields will be fallen back to default
  (``localhost:6600`` without password and ``", "`` as a separator).
* Returns a table with string keys: ``${volume}``, ``${bitrate}``,
  ``${elapsed}`` (in seconds), ``${duration}`` (in seconds),
  ``${Elapsed}`` (formatted as [hh:]mm:ss),
  ``${Duration}`` (formatted as [hh:]mm:ss), ``${Progress}`` (in percentage),
  ``${random}``, ``${repeat}``, ``${state}``, ``${Artist}``, ``${Title}``,
  ``${Artists}`` (all artists concatenated with the configured separator),
  ``${Genres}`` (all genres concatenated with the configured separator),
  ``${Album}``, ``${Genre}`` and optionally ``${Name}`` and ``${file}``.

In addition, some common mpd commands are available as functions:
``playpause``, ``play``, ``pause``, ``stop``, ``next``, ``previous``.
Arguments are of the same form as above, and no value is returned,
e.g. ``vicious.widgets.mpd.playpause()``.

vicious.widgets.net
-------------------

Provides state and usage statistics of network interfaces.

Supported platforms: GNU/Linux, FreeBSD.

* Argument (FreeBSD only): desired interface, e.g. ``"wlan0"``
* Returns (per platform):

  * GNU/Linux: a table with string keys, using net interfaces as a base,
    e.g. ``${eth0 carrier}``, ``${eth0 rx_b}``, ``${eth0 tx_b}``,
    ``${eth0 rx_kb}``, ``${eth0 tx_kb}``, ``${eth0 rx_mb}``,
    ``${eth0 tx_mb}``, ``${eth0 rx_gb}``, ``${eth0 tx_gb}``,
    ``${eth0 down_b}``, ``${eth0 up_b}``, ``${eth0 down_kb}``,
    ``${eth0 up_kb}``, ``${eth0 down_mb}``, ``${eth0 up_mb}``,
    ``${eth0 down_gb}``, ``${eth0 up_gb}``, ``${eth1 rx_b}``, etc.
  * FreeBSD: a table with string keys: ``${carrier}``, ``${rx_b}``, ``${tx_b}``,
    ``${rx_kb}``, ``${tx_kb}``, ``${rx_mb}``, ``${tx_mb}``, ``${rx_gb}``,
    ``${tx_gb}``, ``${down_b}``, ``${up_b}``, ``${down_kb}``, ``${up_kb}``,
    ``${down_mb}``, ``${up_mb}``, ``${down_gb}``, ``${up_gb}``.

vicious.widgets.notmuch
-----------------------

Provides a message count according to an arbitrary Notmuch query.

Supported platforms: platform independent.

Argument: the query that is passed to Notmuch. For instance:
``tag:inbox AND tag:unread`` returns the number of unread messages with
tag "inbox".

Returns a table with string keys containing:

* ``${count}``: the count of messages that match the query


vicious.widgets.org
-------------------

Provides agenda statistics for Emacs org-mode.

Supported platforms: platform independent.

* Argument: an array of full paths to agenda files,
  which will be parsed as arguments.
* Returns an array consisting of

  * ``$1``: Number of tasks you forgot to do
  * ``$2``: Number of tasks for today
  * ``$3``: Number of tasks for the next 3 days
  * ``$4``: Number of tasks to do in the week

vicious.widgets.os
------------------

Provides operating system information.

Supported platforms: platform independent.

Returns an array containing:

* ``$1``: Operating system in use
* ``$2``: Release version
* ``$3``: Username
* ``$4``: Hostname
* ``$5``: Available system entropy
* ``$6``: Available entropy in percent

vicious.widgets.pkg
-------------------

Provides number of pending updates on UNIX systems. Be aware that some package
managers need to update their local databases (as root) before showing the
correct number of updates.

Supported platforms: platform independent, although it requires Awesome
``awful.spawn`` library for non-blocking spawning.

* Argument: distribution name, e.g. ``"Arch"``, ``"Arch C"``, ``"Arch S"``,
  ``"Debian"``, ``"Ubuntu"``, ``"Fedora"``, ``"FreeBSD"``, ``"Mandriva"``.
* Returns an array including:

  * ``$1``: Number of available updates
  * ``$2``: Packages available for update

vicious.widgets.raid
--------------------

Provides state information for a requested RAID array.

Supported platforms: GNU/Linux.

* Argument: the RAID array ID.
* Returns an array containing:

  * ``$1``: Number of assigned devices
  * ``$2``: Number of active devices

vicious.widgets.thermal
-----------------------

Provides temperature levels of several thermal zones.

Supported platforms: GNU/Linux, FreeBSD.

* Argument (per platform):

  * GNU/Linux: either a string - the thermal zone, e.g. ``"thermal_zone0"``,
    or a table of the form ``{thermal_zone, data_source[, input_file]}``.
    Available ``data_source``'s and corresponding default ``input_file``
    are given in the table below.  For instance, if ``"thermal_zone0"``
    is passed, temperature would be read from
    ``/sys/class/thermal/thermal_zone0/temp``.  This widget type is confusing
    and ugly but it is kept for backward compatibility.
  * FreeBSD: either a full ``sysctl`` path to a thermal zone, e.g.
    ``"hw.acpi.thermal.tz0.temperature"``, or a table with multiple paths.

* Returns (per platform):

  * GNU/Linux: an array whose first value is the requested temperature.
  * FreeBSD: a table whose keys are provided paths thermal zones.

===============  ========================  ======================
``data_source``            Path            Default ``input_file``
===============  ========================  ======================
  ``"sys"``      /sys/class/thermal/          ``"temp"``
  ``"core"``     /sys/devices/platform/       ``"temp2_input"``
  ``"hwmon"``    /sys/class/hwmon/            ``"temp1_input"``
  ``"proc"``     /proc/acpi/thermal_zone/     ``"temperature"``
===============  ========================  ======================

vicious.widgets.uptime
----------------------

Provides system uptime and load information.

Supported platforms: GNU/Linux, FreeBSD.

Returns an array containing:

* ``$1``: Uptime in days
* ``$2``: Uptime in hours
* ``$3``: Uptime in minutes
* ``$4``: Load average in the past minute
* ``$5``: Load average in the past 5 minutes
* ``$6``: Load average in the past 15 minutes

vicious.widgets.volume
----------------------

Provides volume levels and state of requested mixers.

Supported platforms: GNU/Linux (requiring ``amixer``), FreeBSD.

* Argument (per platform):

  * GNU/Linux: either a string containing the ALSA mixer control
    (e.g. ``"Master"``) or a table including command line arguments
    to be passed to `amixer(1)`_, e.g. ``{"PCM", "-c", "0"}``
    or ``{"Master", "-D", "pulse"}``
  * FreeBSD: the mixer control, e.g. ``"vol"``

* Returns an array consisting of (per platform):

  * GNU/Linux: ``$1`` as the volume level and ``$2`` as the mute state of
    the requested control
  * FreeBSD: ``$1`` as the volume level of the *left* channel, ``$2`` as the
    volume level of the *right* channel and ``$3`` as the mute state of the
    desired control

vicious.widgets.weather
-----------------------

Provides weather information for a requested station.

Supported platforms: any having Awesome and ``curl`` installed.

* Argument: the ICAO station code, e.g. ``"LDRI"``
* Returns a table with string keys: ``${city}``, ``${wind}``, ``${windmph}``,
  ``${windkmh}``, ``${sky}``, ``${weather}``, ``${tempf}``, ``${tempc}``,
  ``${humid}``, ``${dewf}``, ``${dewc}`` and ``${press}``, ``${when}``

vicious.widgets.wifi
--------------------

Provides wireless information for a requested interface.

Supported platforms: GNU/Linux.

* Argument: the network interface, e.g. ``"wlan0"``
* Returns a table with string keys: ``${ssid}``, ``${mode}``,
  ``${chan}``, ``${rate}`` (Mb/s), ``${freq}`` (MHz),
  ``${txpw}`` (transmission power, in dBm), ``${sign}`` (signal level),
  ``${link}`` and ``${linp}`` (link quality per 70 and per cent)

vicious.widgets.wifiiw
----------------------

Provides wireless information for a requested interface (similar to
vicious.widgets.wifi, but uses ``iw`` instead of ``iwconfig``).

Supported platforms: GNU/Linux.

* Argument: the network interface, e.g. ``"wlan0"``
* Returns a table with string keys: ``${bssid}``, ``${ssid}``,
  ``${mode}``, ``${chan}``, ``${rate}`` (Mb/s), ``${freq}`` (MHz),
  ``${linp}`` (link quality in percent),
  ``${txpw}`` (transmission power, in dBm)
  and ``${sign}`` (signal level, in dBm)

.. _strftime(3): https://linux.die.net/man/3/strftime
.. _app password: https://support.google.com/accounts/answer/185833?hl=en
.. _two step verification: https://support.google.com/accounts/answer/1064203
.. _allow access for less secure apps:
   https://www.google.com/settings/security/lesssecureapps
.. _amixer(1): https://linux.die.net/man/1/amixer
