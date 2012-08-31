---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2012, Andrzje Bieniek <andyhelp@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local setmetatable = setmetatable
local pcall = pcall
local json_status, json = pcall(require, "json")
local io = { popen = io.popen }
local pairs = pairs
local assert = assert
-- }}}

local bb = {} --list of all buildbot builders

local bs = {OK=1, FAILED=2, RUNNING=3}
local bc = {"green", "red", "yellow"}

module("vicious.contrib.buildbot")




BB = {}
BB.__index = BB

function BB.create(url, builder)
    local b = {}
    setmetatable(b,BB)
    b.url = url             -- buildbot url
    b.builder = builder     -- builder name
    b.lastChecked = 0       -- last checked build number
    b.lastSuccessful = 0    -- last successful build number
    b.lastResult = nil      -- last json parsed result
    b.lastError = nil       -- last error string or nil if no error
    return b
end

function BB:_queryBuildbot(build_number)
    local f = io.popen("curl --connect-timeout 1 "..self.url.."/json/builders/"..self.builder.."/builds/"..build_number)
    local jsbuilder = f:read("*all")
    f:close()
    if #jsbuilder == 0 then
       return false, "can't read from url"
    end

    local result_status, result = pcall(json.decode, jsbuilder, false)
    if not result_status then
        return false, "can't parse json data"
    end
    return true, result
end

function BB:_getBuildStatus(result)
    if #result['text'] > 0 then
        local text = result['text']
        if text[1]  == "build" and text[2] == "successful" and #text == 2 then
            --successful
            return bs.OK
        else
            --failed
            return bs.FAILED
        end
    else
        --in progress
        return bs.RUNNING
    end
end

-- Function queries buildbot to refresh builds status.
-- * if build is successful or failed it will not be queried again, number is stored in lasteChecked
-- * up to 10 last builds will be checked to find last successful build
function BB:refresh()
    local last_pass_fail = 0
    local nr = -1
    local last_result
    local iter_counter = 0

    self.lastError = nil
    self.lastResult = nil
    --- there is a gap to fill in, iterate all not checked builds starting from latest
    while nr > self.lastChecked or nr == -1 do
        local r_status, r = self:_queryBuildbot(nr)
        local s

        if not r_status then
            self.lastError = r
            return
        end

        s = self:_getBuildStatus(r)
        if not last_result then
            last_result = r
        end
        nr = r['number']
        assert(nr > 0)
        if last_pass_fail == 0 and (s == bs.OK or s == bs.FAILED) then
            last_pass_fail = nr
        end
        if s == bs.OK then --successful
            self.lastSuccessful = nr
            break;
        end
        nr = nr - 1
        iter_counter = iter_counter + 1
        if iter_counter > 10 then  --check max last 10 builds when searching for successful build
            break;
        end
     end
     if last_pass_fail ~= 0 then
         self.lastChecked = last_pass_fail
     end
     if last_result then
         self.lastResult = last_result
     end
end

function BB:getLastSuccessful()
    return self.lastSuccessful
end

function BB:getCurrent()
    return self.lastResult['number']
end

function BB:getCurrentStatus()
    return self:_getBuildStatus(self.lastResult)
end

function BB:getBuilder()
    return self.builder
end

function BB:getError()
    return self.lastError
end


local function getBuilderStatus(b)
    local s = "[" .. b:getBuilder()
    --check if json library was loaded correctly
    if not json_status then
        return s .. ".<span color=\"orange\">can't find libluaX.X-json</span>]"
    end

    local err = b:getError()
    if err then
        return s .. ".<span color=\"orange\">" .. err .. "</span>]"
    end

    if b:getLastSuccessful() ~= 0 then
        success_build_nr_str = "<span color=\"green\">".. b:getLastSuccessful() .."</span>"
    else
        success_build_nr_str = "-"
    end

    local current_build_color = bc[b:getCurrentStatus()]
    current_build_nr_str = "<span color=\""..current_build_color.."\">"..b:getCurrent().."</span>"

    if current_build_color ~= "green" then
        s = s .. "." .. current_build_nr_str
    end
    return s .. "." .. success_build_nr_str .. "]"
end


-- {{{ Buildbot widget type
local function worker(format, warg)
    if #bb == 0 then    --fill up bb with builders when worker function is run for the first time
        for i,v in pairs(warg) do
            bb[#bb+1] = BB.create(v["url"], v["builder"])
        end
    end

    local str = ""
    for i,v in pairs(bb) do
        v:refresh()
        str = str .. " " .. getBuilderStatus(v)
    end
    return {str .. " "}
end
-- }}}

setmetatable(_M, { __call = function(_, ...) return worker(...) end })

