# Contrib

Contrib libraries, or widget types, are extra snippets of code you can
use. Some are for less common hardware, and other were contributed by
Vicious users. The contrib directory also holds widget types that were
obsoleted or rewritten. Contrib widgets will not be imported by init
unless you explicitly enable it, or load them in your rc.lua.

## Usage within Awesome

To use contrib widgets uncomment the line that loads them in
init.lua. Or you can load them in your rc.lua after you require
Vicious:

```lua
local vicious = require("vicious")
vicious.contrib = require("vicious.contrib")
```

## Widget types

Most widget types consist of worker functions that take the `format`
argument given to vicious.register as the first argument, `warg` as
the second, and return a table of values to insert in the format
string. But we have not insisted on this coding style in contrib. So
widgets like PulseAudio have emerged that are different. These widgets
could also depend on Lua libraries that are not distributed with the
core Lua distribution. Ease of installation and use does not
necessarily have to apply to contributed widgets.

### vicious.contrib.ac

Provide status about the power supply (AC).

Supported platforms: GNU/Linux, requiring `sysfs`.

* Argument: the AC device, i.e `"AC"` or `"ACAD"`. The device is linked under
  `/sys/class/power_supply/` and should have a file called `online`.
* Returns `{"On"}` if AC is connected, else `{"Off"}`. If AC doesn't exist,
  returns `{"N/A"}`.

### vicious.contrib.ati

Provides various info about ATI GPU status.

Supported platforms: GNU/Linux, requiring `sysfs`.

* Argument: card ID, e.g. `"card0"` (and where possible,
  uses `debugfs` to gather data on radeon power management)
* Returns a table with string keys: `${method}`, `${dpm_state}`,
  `${dpm_perf_level}`, `${profile}`, `${engine_clock mhz}`,
  `${engine_clock khz}`, `${memory_clock mhz}`, `${memory_clock khz}`,
  `${voltage v}`, `${voltage mv}`

### vicious.contrib.batpmu

### vicious.contrib.batproc

### vicious.contrib.btc

Provides current Bitcoin price in any currency by
[code](https://en.wikipedia.org/wiki/ISO_4217).


Platform independent, although requiring `curl` and either
[lua-cjson](https://github.com/mpx/lua-cjson/) or
[luajson](https://github.com/harningt/luajson/).

* Argument: currency code, e.g. `"usd"`, `"rub"` and other. Default to `"usd"`.
* Returns a table with string key `${price}`.

### vicious.contrib.buildbot

Provides last build status for configured buildbot builders
(http://trac.buildbot.net/).

Supported platforms: platform independent, though requiring Lua JSON parser
[luajson](https://github.com/harningt/luajson/).

Returns build status in the format:
`[<builderName>.<currentBuildNumber>.<lastSuccessfulBuildNumber>]`.
If `<currentBuildNumber>` is the same as `<lastSuccessfulBuildNumber>` only one
number is displayed. `<buildNumber>` colors: red - failed, green - successful,
yellow - in progress.

### vicious.contrib.countfiles

### vicious.contrib.cmus

Provides cmus player information using `cmus-remote`.

Supported platforms: platform independent.

* Argument: a table whose first field is the socket including host (or nil).
* Returns a table with string keys: `${status}`, `${artist}`, `${title}`,
  `${duration}`, `${file}`,  `${continue}`, `${shuffle}`, `${repeat}`.

### vicious.contrib.dio

Provides I/O statistics for requested storage devices.

* Argument: the disk as an argument, i.e. `"sda"`, or a specific
  partition, i.e. `"sda/sda2"`
* Returns a table with string keys: `${total_s}`, `${total_kb}`, `${total_mb}`,
  `${read_s}`, `${read_kb}`, `${read_mb}`, `${write_s}`, `${write_kb}`,
  `${write_mb}` and `${sched}`

### vicious.contrib.mpc

### vicious.contrib.netcfg

### vicious.contrib.net

### vicious.contrib.openweather

Provides weather information for a requested city

* Argument: OpenWeatherMap city ID, e.g. `"1275339"`
* Returns a table with string keys: `${city}`, `${wind deg}`, `${wind aim}`,
  `${wind kmh}`, `${wind mps}`, `${sky}`, `${weather}`, `${temp c}`,
  `${humid}` and `${press}`

### vicious.contrib.nvinf

Provides GPU utilization, core temperature, clock frequency information about
Nvidia GPU from nvidia-settings

Supported Platforms: platform independent

* Argument (optional): card ID as an argument, e.g. `"1"`, default to ID 0
* Returns an array containing:
    * `$1`: Usage of GPU core
    * `$2`: Usage of GPU memory
    * `$3`: Usage of video engine
    * `$4`: Usage of PCIe bandwidth
    * `$5`: Uemperature of requested graphics device
    * `$6`: Urequency of GPU core
    * `$7`: Uemory transfer rate

### vicious.contrib.nvsmi

Provides (very basic) information about Nvidia GPU status from SMI

Supported platforms: platform independent

* Argument (optional): card ID as an argument, e.g. `"1"`, default to ID 0
* Returns an array containing temperature of requested graphics device

### vicious.contrib.ossvol

### vicious.contrib.pop

### vicious.contrib.pulse

Provides volume levels of requested pulseaudio sinks and functions to
manipulate them

* Argument (optional): name of a sink as an optional argument. A number will
  be interpret as an index, if no argument is given, it will take the
  first-best. To get a list of available sinks run
  `pacmd list-sinks | grep 'name:'`.
* Returns an array whose only element is the volume level

#### vicious.contrib.pulse.add(percent[, sink])

* `percent` is the percentage to increment or decrement the volume from its
  current value
* Returns the exit status of `pacmd`

#### vicious.contrib.pulse.toggle([sink])

* Toggles mute state
* Returns the exit status of `pacmd`

### vicious.contrib.rss

### vicious.contrib.sensors

### vicious.contrib.wpa

Provides information about the wifi status.

Supported Platforms: platform independent, requiring `wpa_cli`.

* Argument: the interface, e.g. `"wlan0"` or `"wlan1"`
* Returns a table with string keys: `${ssid}`, `${qual}`, `${ip}`, `${bssid}`

## Usage examples

### Pulse Audio widget:

```lua
vol = wibox.widget.textbox()
local sink = "alsa_output.pci-0000_00_1b.0.analog-stereo"
vicious.register(vol, vicious.contrib.pulse, " $1%", 2, sink)
vol:buttons(awful.util.table.join(
    awful.button({}, 1, function () awful.util.spawn("pavucontrol") end),
    awful.button({}, 4, function () vicious.contrib.pulse.add(5, sink) end),
    awful.button({}, 5, function () vicious.contrib.pulse.add(-5, sink) end)))
```

### Buildbot widget

```lua
buildbotwidget = wibox.widget.textbox()
vicious.register(
    buildbotwidget, vicious.contrib.buildbot, "$1,", 3600,
    {{builder="coverage", url="http://buildbot.buildbot.net"},
     {builder="tarball-slave", url="http://buildbot.buildbot.net"}})
```
