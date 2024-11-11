Changelog
=========

Changes in 2.7.1
----------------

Fixed:

- [bat_linux] Fallback to computing bat (dis)charge rate in some cases

Changes in 2.7.0
----------------

Added fields ``${Artists}`` and ``${Genres}`` for the mpd widget type.

Changes in 2.6.0
----------------

Added AMD GPU widget type for Linux.

Fixed typos in contrib widgets documentation.

Changes in 2.5.1
----------------

Fixed:

- Escaping of % in ``helpers.format``, which affects mpd widget ``${Progress}``
- Possible deadlock of when ``update`` widgets
- [contrib.openweather] New API compatibility, which requires an API key
- [gmail] Authentication documentation

Added:

- [mpd] Support for sending arbitrary commands
- [contrib.openweather] Various new return values

Changes in 2.5.0
----------------

Fixed:

- ``vicious.call`` freezing awesome when used with asynchronous widget types

Added:

- ``vicious.call_async`` asynchronous analogous to ``vicious.call``

Moved:

- Most of the documentation in READMEs to ``docs/``
- ``Changes.md`` to ``CHANGELOG.rst``
- ``CONTRIBUTING.md`` to ``CONTRIBUTING.rst``
- Meta helpers to ``tools/``

Changes in 2.4.2
----------------

Feature: [hwmontemp] Bring back sysfs path cache

Changes in 2.4.1
----------------

Fixed:

- [pkg] Fallback the number of lines before packages listing to 0.
  This fixes crashes on Arch, FreeBSD and Mandriva.
- [mdir] Remove trailing semicolon at the end of command.

Changes in 2.4.0
----------------

.. important::

   ``volume`` now uses 🔉 and 🔈 instead of ♫ and ♩ to show mute state.
   This BREAKS backward compatibility if users substitute custom symbols
   from these default.

Added:

- notmuch_all, cpu_freebsd widget types.
- [cmus_all] Promote to ``widgets/``.
- [wifiiw_linux] Expose BSSID.
- [wifi_linux] Expose frequency and transmission power.
- ``spawn`` as a fallback for ``awful.spawn`` in case Vicious is used as
  a stand-alone library. This wrapper, however, does NOT provide the facilities
  to asynchronously spawn new processes. It also lacks a few features such as
  parsing ``stderr`` and returning PID.
- ``helpers.setasyncall`` to avoid writing redundant workers for asynchronous
  widget types. Note that these workers are only needed in case Vicious is used
  as a stand-alone library.
- ``helpers.setcall`` for registering functions as widget types.
- ``headergen`` script for automatic generation of copyright notices.
- ``templates`` for the ease of adding new widget types.
- ``CONTRIBUTING.md`` which guide contributors through the steps
  of filing an issue or submitting a patch.

Fixed:

- Deprecate the use of ``io.popen`` in following widgets:

  - wifi_linux, wifiiw_linux, hwmontemp_linux, hddtemp_linux
  - bat_freebsd, mem_freebsd, net_freebsd, thermal_freebsd, uptime_freebsd,
  - cpu_freebsd, cpufreq_freebsd, fanspeed_freebsd
  - bat_openbsd
  - volume, gmail, mdir, mpd, fs

- [mpd] Lua 5.3 compatibility (for real this time); also correct a typo
- [mbox] Update the deprecated ``string.gfind`` to ``string.gmatch``
- [pkg,weather,contrib/btc] Allow function call without Awesome
- [pkg] Use more updated front-ends for Debian/Ubuntu (apt) and Fedora (dnf)
- [os] Splitted os_all into os_linux and os_bsd (and refactored to async)
- Tweak ``.luacheckrc`` to suit functional style and soft-limit text width to 80
- Update copyright headers for libraries and widget types

Removed:

- ``helpers.sysctl`` and ``helpers.sysctl_table`` were removed in favour of
  ``helpers.sysctl_async``.

Changes in 2.3.3
----------------

Feature: Add battery widget type for OpenBSD

Fixes:

- [mpd] Lua 5.3 compatibility
- [bat_freebsd] Update battery state symbols

Changes in 2.3.2
----------------

Features:

- Support stacked graphs
- [hwmontemp_linux] Provide name-based access to hwmon sensors via sysfs
- [mpd_all] Expose more informations and format time in [hh:]mm:ss

Fixes:

- Improve defaults and mechanism for data caching
- Escape XML entities in results by default
- [weather_all] Update NOAA link and use Awesome asynchronous API
- [mem_linux] Use MemAvailable to calculate free amount
- [mem_freebsd] Correct calculation and switch to swapinfo for swap
- [bat_freebsd] Add critical charging state
- [fs_all] Fix shell quoting of option arguments

Moreover, ``.luacheckrc`` was added and ``README.md`` was refomatted
for the ease of development.

Changes in 2.3.1
----------------

Fixes:

- widgets can be a function again (regression introduced in 2.3.0)

Changes in 2.3.0
----------------

Features:

- add btc widget
- add cmus widget
- alsa mixer also accept multiple arguments

Fixes:

- pkg now uses non-blocking asynchronous api

Changes in 2.2.0
----------------

Notable changes:

- moved development from git.sysphere.org/vicious to github.com/Mic92/vicious
- official freebsd support
- escape variables before passing to shell
- support for gear timers
- fix weather widget url
- add :lua:func:`vicious.call` method to obtain data outside of widgets

For older versions please see ``git log``.
