# Changes in 2.4.0 (WIP)

IMPORTANT:

- `volume` now uses 🔉 and 🔈 instead of ♫ and ♩ to show mute state.
  This BREAKS backward compatibility if users substitute custom symbols
  from these default.

Added:

- [wifi_linux] Expose frequency and transmission power
- `spawn` as a fallback for `awful.spawn` in case Vicious is used as
  a stand-alone library. This wrapper, however, does NOT provide the facilities
  to asynchronously spawn new processes. It also lacks a few features such as
  parsing `stderr` and returning PID.
- `helpers.setasyncall` to avoid writing redundant workers for asynchronous
  widget types. Note that these workers are only needed in case Vicious is used
  as a stand-alone library.

Fixed:

- Deprecate the use of `io.popen` in following widgets:
    * wifi_linux, wifiiw_linux, hwmontemp_linux, hddtemp_linux
    * bat_freebsd, mem_freebsd, net_freebsd, thermal_freebsd, uptime_freebsd,
      cpu_freebsd, cpufreq_freebsd, fanspeed_freebsd
    * bat_openbsd
    * volume, gmail, mdir, mpd, fs
- [mpd] Lua 5.3 compatibility (for real this time); also correct a typo
- [pkg,weather,contrib/btc] Allow function call without Awesome
- [pkg] Use more updated front-ends for Debian/Ubuntu (apt) and Fedora (dnf)
- [os] Splitted os_all into os_linux and os_bsd (and refactored to async)
- Tweak `.luacheckrc` to suit functional style and soft-limit text width to 80

Removed:

- `helpers.sysctl` and `helpers.sysctl_table` were removed in favour of
  `helpers.sysctl_async`.

# Changes in 2.3.3

Feature: Add battery widget type for OpenBSD

Fixes:

- [mpd] Lua 5.3 compatibility
- [bat\_freebsd] Update battery state symbols

# Changes in 2.3.2

Features:

- Support stacked graphs
- [hwmontemp\_linux] Provide name-based access to hwmon sensors via sysfs
- [mpd\_all] Expose more informations and format time in [hh:]mm:ss

Fixes:

- Improve defaults and mechanism for data caching
- Escape XML entities in results by default
- [weather\_all] Update NOAA link and use Awesome asynchronous API
- [mem\_linux] Use MemAvailable to calculate free amount
- [mem\_freebsd] Correct calculation and switch to swapinfo for swap
- [bat\_freebsd] Add critical charging state
- [fs\_all] Fix shell quoting of option arguments

Moreover, `.luacheckrc` was added and `README.md` was refomatted for the ease
of development.

# Changes in 2.3.1

Fixes:

- widgets can be a function again (regression introduced in 2.3.0)

# Changes in 2.3.0

Features:
- add btc widget
- add cmus widget
- alsa mixer also accept multiple arguments

Fixes:

- pkg now uses non-blocking asynchronous api

# Changes in 2.2.0

Notable changes:

- moved development from git.sysphere.org/vicious to github.com/Mic92/vicious
- official freebsd support
- escape variables before passing to shell
- support for gear timers
- fix weather widget url
- add vicious.call() method to obtain data outside of widgets

For older versions see git log
