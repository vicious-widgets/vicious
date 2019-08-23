-- Only allow symbols available in all Lua versions
std = "min"

-- Global objects defined by the C code
read_globals = {
    "timer",    -- deprecated, but used in older versions.
}

-- Warnings to be ignored
ignore = {
    "212",  -- Unused argument.
}

-- Not enforced, but preferable
max_code_line_length = 80

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
