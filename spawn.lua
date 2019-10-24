-- wrapper around Awesome awful.spawn with fallback
-- Copyright (C) 2019  Nguyễn Gia Phong <vn.mcsinyx@gmail.com>
--
-- This file is part of Vicious.
--
-- Vicious is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as
-- published by the Free Software Foundation, either version 2 of the
-- License, or (at your option) any later version.
--
-- Vicious is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Vicious.  If not, see <https://www.gnu.org/licenses/>.

local status, awful = pcall(require, "awful")
if status then
    local spawn = awful.spawn
    function spawn.with_line_callback_with_shell(cmd, callbacks)
        spawn.with_line_callback({ awful.util.shell, "-c", cmd }, callbacks)
    end
    return spawn
end

local io = { popen = io.popen }

-- In case the Awesome library is not available,
-- fall back to this synchronous, handicapped API.
local spawn = {}

--- Spawn a program and capture its output line by line.
-- @tparam string cmd The command.
-- @tab callbacks Table containing callbacks that should be invoked on
--   various conditions.
-- @tparam[opt] function callbacks.stdout Function that is called with each
--   line of output on stdout, e.g. `stdout(line)`.
-- @tparam[opt] function callbacks.stderr Function that is supposed to be called
--   with each line of output on stderr, but due to limitation of io.popen,
--   stderr will be discarded (sorry!).
-- @tparam[opt] function callbacks.output_done Function to call when no more
--   output is produced.
-- @tparam[opt] function callbacks.exit Function to call when the spawned
--   process exits. This function gets the exit reason and code as its
--   arguments.
--   The reason can be "exit" or "signal".
--   For "exit", the second argument is the exit code.
--   For "signal", the second argument is the signal causing process
--   termination.
-- @treturn boolean|nil true if cmd terminated successfully, or nil otherwise
function spawn.with_line_callback_with_shell(cmd, callbacks)
    local stdout_callback, stdout = callbacks.stdout, io.popen(cmd)
    if stdout_callback then
        for line in stdout:lines() do stdout_callback(line) end
    end
    if callbacks.output_done then callbacks.output_done() end

    local success, reason, code = stdout:close()    -- this requires Lua 5.2
    if callbacks.exit then callbacks.exit(reason, code) end
    return success
end

--- Spawn a program and capture its output.
-- @tparam string cmd The command.
-- @tab callback Function with the following arguments
--   @tparam string callback.stdout Output on stdout.
--   @tparam string callback.stderr Output on stderr,
--     which will be an empty due to limitation of io.popen.
--   @tparam string callback.exitreason Exit reason ("exit" or "signal").
--   @tparam integer callback.exitcode Exit code (exit code or signal number,
--     depending on "exitreason").
-- @treturn boolean|nil true if cmd terminated successfully, or nil otherwise
function spawn.easy_async_with_shell(cmd, callback)
    local out_stream = io.popen(cmd)
    local stdout = out_stream:read("*all")
    local success, reason, code = out_stream:close()    -- requiring Lua 5.2
    callback(stdout, "", reason, code)
    return success
end

-- Since io.popen always use a shell
spawn.easy_async = spawn.easy_async_with_shell
spawn.with_line_callback = spawn.with_line_callback_with_shell

return spawn
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
