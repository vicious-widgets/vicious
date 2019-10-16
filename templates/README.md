# Widget type templates

Before writing a new widget type, make sure to ask yourself if anyone is going
to need the feature.  Only widget types that you (or an incapacitated friend
you can personally talk to) require would be merged.  Do not file PRs because
they seem like a good idea.  If they're really useful, they'll be requested
in the issue tracker.

Additionally, too simple widget types (e.g. an one-liner) and those that
are not modular enough are very unlikely to be merged.  By *modular*, we mean

> constructed with standardized units or dimensions
> allowing flexibility and variety in use

If all the above conditions are met, you can start from one of the templates
in this directory:

* `sync.lua`: synchronous widget type that does not fork
* `async.lua`: asynchronous widget type for fetching informations using
  a command-line utility.  As a rule of thumb, if your widget type uses
  `io.popen`, you would need to refactor it to use async facilities.

Your widget types should be placed in `widgets`: the `contrib` directory
exists only for historical reasons and is barely maintained anymore.
The filenames should be of the form `<name>_<platform>.lua`, whereas

* `<name>` is a single (alphanumeric) word, preferably in lowercase
* `<platform>` is the OS that the widget type works on.
  At the time of writing these are supported:
    - `freebsd`: FreeBSD
    - `openbsd`: OpenBSD
    - `bsd`: all \*BSDs listed above
    - `linux`: GNU/Linux
    - `all`: all of the above

Please be aware of `luacheck`, which may help you during the progress.
From `widgets`, run

    luacheck --config .luacheckrc ..

After finishing the widget type, you should document its usage in the project's
`README.md`.  Try to provide at least

* A brief description
* The list of supported platforms
* Type and structures of the arguments that the widget type passes
  (`format` and `warg`), with unused parameters omitted
* Type and structure of the return value
