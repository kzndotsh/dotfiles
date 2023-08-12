VERSION = "1.0.5"

-- micro
local micro = import("micro")
local config = import("micro/config")
local util = import("micro/util")
local shell = import("micro/shell")
-- golang
local filepath = import("filepath")
local http = import("http")
local ioutil = import("io/ioutil")
local os2 = import("os")
local runtime = import("runtime")
-- wakatime
local userAgent = "micro/" .. util.SemVersion:String() .. " micro-wakatime/" .. VERSION
local s3Urlprefix = "https://wakatime-cli.s3-us-west-2.amazonaws.com/"
local lastFile = ""
local lastHeartbeat = 0

function init()
    config.MakeCommand("wakatime.apikey", promptForApiKey, config.NoComplete)

    micro.InfoBar():Message("WakaTime initializing...")
    micro.Log("initializing WakaTime v" .. VERSION)

    checkCli()
    checkApiKey()
end

function postinit()
    micro.InfoBar():Message("WakaTime initialized")
    micro.Log("WakaTime initialized")
end

function checkCli()
    if not cliUpToDate() then
        downloadCli()
    end
end

function checkApiKey()
    if not hasApiKey() then
        promptForApiKey()
    end
end

function hasApiKey()
    return getApiKey() ~= nil
end

function getApiKey()
    return getSetting("settings", "api_key")
end

function getConfigFile()
    return filepath.Join(os2.UserHomeDir(), ".wakatime.cfg")
end

function getSetting(section, key)
    config, err = ioutil.ReadFile(getConfigFile())
    if err ~= nil then
        micro.InfoBar():Message("failed reading ~/.wakatime.cfg")
        micro.Log("failed reading ~/.wakatime.cfg")
        micro.Log(err)
    end

    lines = util.String(config)
    currentSection = ""

    for line in lines:gmatch("[^\r\n]+") do
        line = string.trim(line)
        if string.starts(line, "[") and string.ends(line, "]") then
            currentSection = string.lower(string.sub(line, 2, string.len(line) -1))
        elseif currentSection == section then
            parts = string.split(line, "=")
            currentKey = string.trim(parts[1])
            if currentKey == key then
                return string.trim(parts[2])
            end
        end
    end

    return ""
end

function setSetting(section, key, value)
    config, err = ioutil.ReadFile(getConfigFile())
    if err ~= nil then
        micro.InfoBar():Message("failed reading ~/.wakatime.cfg")
        micro.Log("failed reading ~/.wakatime.cfg")
        micro.Log(err)
        return
    end

    contents = {}
    currentSection = ""
    lines = util.String(config)
    found = false

    for line in lines:gmatch("[^\r\n]+") do
        line = string.trim(line)
        if string.starts(line, "[") and string.ends(line, "]") then
            if currentSection == section and not found then
                table.insert(contents, key .. " = " .. value)
                found = true
            end

            currentSection = string.lower(string.sub(line, 2, string.len(line) -1))
            table.insert(contents, string.rtrim(line))
        elseif currentSection == section then
            parts = string.split(line, "=")
            currentKey = string.trim(parts[1])
            if currentKey == key then
                if not found then
                    table.insert(contents, key .. " = " .. value)
                    found = true
                end
            else
                table.insert(contents, string.rtrim(line))
            end
        else
            table.insert(contents, string.rtrim(line))
        end
    end

    if not found then
        if currentSection ~= section then
            table.insert(contents, "[" .. section .. "]")
        end

        table.insert(contents, key .. " = " .. value)
    end

    _, err = ioutil.WriteFile(getConfigFile(), table.concat(contents, "\n"), 0700)
    if err ~= nil then
        micro.InfoBar():Message("failed saving ~/.wakatime.cfg")
        micro.Log("failed saving ~/.wakatime.cfg")
        micro.Log(err)
        return
    end

    micro.Log("~/.wakatime.cfg successfully saved")
end

function downloadCli()
    local io = import("io")
    local zip = import("archive/zip")

    local url = s3BucketUrl() .. "wakatime-cli.zip"
    local zipFile = filepath.Join(resourcesFolder(), "wakatime-cli.zip")

    micro.InfoBar():Message("downloading wakatime-cli...")
    micro.Log("downloading wakatime-cli from " .. url)

    _, err = os2.Stat(resourcesFolder())
    if os2.IsNotExist(err) then
        os.execute("mkdir " .. resourcesFolder())
    end

    -- download cli
    local res, err = http.Get(url)
    if err ~= nil then
        micro.InfoBar():Message("error downloading wakatime-cli.zip")
        micro.Log("error downloading wakatime-cli.zip")
        micro.Log(err)
        return
    end

    out, err = os2.Create(zipFile)
    if err ~= nil then
        micro.InfoBar():Message("error creating new wakatime-cli.zip")
        micro.Log("error creating new wakatime-cli.zip")
        micro.Log(err)
        return
    end

    _, err = io.Copy(out, res.Body)
    if err ~= nil then
        micro.InfoBar():Message("error saving wakatime-cli.zip")
        micro.Log("error saving wakatime-cli.zip")
        micro.Log(err)
        return
    end

    err = util.Unzip(zipFile, resourcesFolder())
    os2.Remove(zipFile)

    if err ~= nil then
        micro.InfoBar():Message("failed to unzip wakatime-cli.zip")
        micro.Log("failed to unzip wakatime-cli.zip")
        micro.Log(err)
        return
    end
end

function resourcesFolder()
    return filepath.Join(os2.UserHomeDir(), ".wakatime")
end

function cliPath()
    local ext = ""

    if isWindows() then
        ext = ".exe"
    end

    return filepath.Join(resourcesFolder(), "wakatime-cli", ("wakatime-cli" .. ext))
end

function cliExists()
    local _, err = os2.Stat(cliPath())

    if os2.IsNotExist(err) then
        return false
    end

    return true
end

function cliUpToDate()
    if not cliExists() then
        return false
    end

    local ioutil = import("ioutil")
    local fmt = import("fmt")

    local url = s3BucketUrl() .. "current_version.txt"

    -- get current version from installed cli
    local currentVersion, err = shell.ExecCommand(cliPath(), "--version")
    if err ~= nil then
        micro.InfoBar():Message("failed to determine current cli version")
        micro.Log("failed to determine current cli version")
        micro.Log(err)
        return true
    end

    micro.Log("Current wakatime-cli version is " .. currentVersion)
    micro.Log("Checking for updates to wakatime-cli...")

    -- read version from S3
    local res, err = http.Get(url)
    if err ~= nil then
        micro.InfoBar():Message("error retrieving wakatime-cli version from S3")
        micro.Log("error retrieving wakatime-cli version from S3")
        micro.Log(err)
        return true
    end

    body, err = ioutil.ReadAll(res.Body)
    if err ~= nil then
        micro.InfoBar():Message("error reading all bytes from response body")
        micro.Log("error reading all bytes from response body")
        micro.Log(err)
        return true
    end

    -- parse byte array to string
    latestVersion = util.String(body)

    if string.gsub(latestVersion, "[\n\r]", "") == string.gsub(currentVersion, "[\n\r]", "") then
        micro.Log("wakatime-cli is up to date")
        return true
    end

    micro.Log("Found an updated wakatime-cli v" .. latestVersion)

    return false
end

function s3BucketUrl()
    if runtime.GOOS == "darwin" then
        return s3Urlprefix .. "mac-x86-64/"
    elseif runtime.GOOS == "windows" then
        return s3Urlprefix .. "windows-x86-" .. getOsArch() .. "/"
    else
        return s3Urlprefix .. "linux-x86-64/"
    end
end

function getOsArch()
    local arch

    if (os.getenv"os" or ""):match"^Windows" then
        arch = os.getenv"PROCESSOR_ARCHITECTURE"
    else
        arch = io.popen"uname -m":read"*a"
    end

    if (arch or ""):match"64" then
        return "64"
    else
        return "32"
    end
end

function isWindows()
    return runtime.GOOS == "windows"
end

function onSave(bp)
    onEvent(bp.buf.AbsPath, true)

    return true
end

function onSaveAll(bp)
    onEvent(bp.buf.AbsPath, true)

    return true
end

function onSaveAs(bp)
    onEvent(bp.buf.AbsPath, true)

    return true
end

function onOpenFile(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onPaste(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onSelectAll(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onDeleteLine(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onCursorUp(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onCursorDown(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onCursorPageUp(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onCursorPageDown(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onCursorLeft(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onCursorRight(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onCursorStart(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onCursorEnd(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onSelectToStart(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onSelectToEnd(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onSelectUp(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onSelectDown(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onSelectLeft(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onSelectRight(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onSelectToStartOfText(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onSelectToStartOfTextToggle(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onWordRight(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onWordLeft(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onSelectWordRight(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onSelectWordLeft(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onMoveLinesUp(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onMoveLinesDown(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onScrollUp(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function onScrollDown(bp)
    onEvent(bp.buf.AbsPath, false)

    return true
end

function enoughTimePassed(time)
    return lastHeartbeat + 120000 < time
end

function onEvent(file, isWrite)
    time = os.time()
    if isWrite or enoughTimePassed(time) or lastFile ~= file then
        sendHeartbeat(file, isWrite)
        lastFile = file
        lastHeartbeat = time
    end
end

function sendHeartbeat(file, isWrite)
    micro.Log("Sending heartbeat")

    local isDebugEnabled = getSetting("settings", "debug"):lower()
    local args = {"--entity", file, "--plugin", userAgent}

    if isWrite then
        table.insert(args, "--write")
    end

    if isDebugEnabled then
        table.insert(args, "--verbose")
    end

    -- run it in a thread
    shell.JobSpawn(cliPath(), args, nil, sendHeartbeatStdErr, sendHeartbeatExit)
end

function sendHeartbeatStdErr(err)
    micro.Log(err)
    micro.Log("Check your ~/.wakatime.log file for more details.")
end

function sendHeartbeatExit(out, args)
    micro.Log("Last heartbeat sent " .. os.date("%c"))
end

function promptForApiKey()
    micro.InfoBar():Prompt("API Key: ", getApiKey(), "api_key", function(input)
        return
    end, function(input, canceled)
        if not canceled then
            if isValidApiKey(input) then
                setSetting("settings", "api_key", input)
            else
                micro.Log("Api Key not valid!")
            end
        end
    end)
end

function isValidApiKey(key)
    if key == "" then
        return false
    end

    local regexp = import("regexp")

    matched, _ = regexp.MatchString("(?i)^(waka_)?[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$", key)

    return matched
end

function ternary (cond, T, F)
    if cond then return T else return F end
end

function string.starts(str, start)
    return str:sub(1,string.len(start)) == start
end

function string.ends(str, ending)
    return ending == "" or str:sub(-string.len(ending)) == ending
end

function string.trim(str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

function string.rtrim(str)
    local n = #str
    while n > 0 and str:find("^%s", n) do n = n - 1 end
    return str:sub(1, n)
end

function string.split(str, delimiter)
    t = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(t, match);
    end
    return t
end
