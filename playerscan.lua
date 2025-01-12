--[[
####################
##    Version     ##
##     1.0.0      ##
####################

-> 1.0.0: Initial release

####################################################
##                  Description                   ##
####################################################

Uses the player search function to find all online players on a given world.
Can be used to automatically travel between worlds and search on each one.
Might or might not be useful for other plugins.

####################################################
##                  Requirements                  ##
####################################################

-> Lifestream : https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
-> PlayerScope : https://raw.githubusercontent.com/sicakbirtebessum/PlayerScope/master/repo.json
-> Something Need Doing (Expanded Edition) : https://puni.sh/api/repository/croizat

#####################
##    Settings     ##
###################]]

local repeat_search = false -- Options: true = will repeat search, false = will not repeat search
local multi_world_search = false -- Options: true = will search on the worlds you input below, false = will search on your current world only
local worlds_list = { "Alpha", "Lich", "Odin", "Phoenix", "Raiden", "Shiva", "Twintania", "Zodiark" } -- List of worlds you want to search, only used if multi_world_search is set to true

--[[################################################
##                  Script Start                  ##
##################################################]]

snd_config_folder = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
load_functions_file_location = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\vac_functions.lua"
LoadFunctions = loadfile(load_functions_file_location)
LoadFunctions()
LoadFileCheck()

if not CheckPluginsEnabled("SomethingNeedDoing") then
    return -- Stops script as plugins not available
end

if HasPlugin("YesAlready") then
    PauseYesAlready()
end

local function PerformSearch(command, name)
    yield(command .. " first " .. name)

    local previous_count = GetNodeText("SocialList", 3)
    local count_difference = 0
    local total_checks = 0

    while count_difference < 3 and total_checks < 20 do -- 3 checks (1.5 seconds) or max 10 seconds
        Sleep(0.5)
        total_checks = total_checks + 1
        local current_count = GetNodeText("SocialList", 3)

        if string.match(current_count, "^19[7-9]/200$") or current_count == "200/200" then -- Checks between 197-200 to be considered max count
            return true -- Max player count reached
        elseif current_count == previous_count then
            count_difference = count_difference + 1
        else
            count_difference = 0
            previous_count = current_count
        end
    end
    return false -- Did not hit max player count
end

local function SearchWorld(world)
    if multi_world_search then
        Teleporter(world, "li") -- Teleport to the specified world
        Echo("Searching on world: " .. world)
    else
        Echo("Searching on current world")
    end

    local levels = { "1-20", "21-40", "41-60", "61-80", "81-100" }

    for i = 97, 122 do -- ASCII characters for lowercase a-z
        local letter = string.char(i)

        -- Attempt the full combination first
        if PerformSearch("/sea jp en de fr ", letter) then
            Echo("Max player count for '" .. letter .. "', trying individual levels")

            -- Try each level individually if the full combination hits max
            for _, level in ipairs(levels) do
                PerformSearch("/sea jp en de fr " .. level, letter)
            end
        end
    end
end

local function Main()
    repeat
        if multi_world_search then
            for _, world in ipairs(worlds_list) do
                SearchWorld(world)
            end
            Echo("Finished iterating through all letters on all worlds.")
        else
            SearchWorld(GetCurrentWorld())
            Echo("Finished iterating through all letters.")
        end
    until not repeat_search
end

Main()

if HasPlugin("YesAlready") then
    RestoreYesAlready()
end