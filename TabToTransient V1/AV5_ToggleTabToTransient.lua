--User Variables
fileNameTabPrev = "AV5_TabTransientPrev.lua"
fileNameTabNext = "AV5_TabTransientNext.lua"
enableDebug = false
--[[
Script: Toggle Tab to transient

Description: u/thatpaxguy requested a Toggle Tab to Transient. Fixed clunky method.

V1.1: As of now, this works 100% on a Mac. Gotta test it on Win still.

Script by Alberto Valdez at av5sound.com and u/Sound4Sound
--]]

local function ReadFile(directory, fileName)
	local allLines = {}
	local file = io.open(directory..fileName, "r")
	for line in file:lines() do 
		table.insert(allLines,line) end

	if allLines[1] == "tabToTransient = false" then toggle = false
	elseif allLines[1] == "tabToTransient = true" then toggle = true
	end
	if enableDebug == true then reaper.ShowConsoleMsg("\n\nTOGGLE: "..tostring(toggle)) end
	file:close()
end

local function Toggle()
	if toggle == true then
		toggle = false
		return "tabToTransient = false"
	elseif toggle == false then
		toggle = true
		return "tabToTransient = true"
	end
end

local function WriteFiles(directory)
	local t = Toggle()
	file = io.open(directory..fileNameTabPrev,"w")
	line1 = t.."\nif tabToTransient == true and reaper.CountSelectedMediaItems(0) > 0 then reaper.Main_OnCommand(40376, 1)\nelse reaper.Main_OnCommand(40318,1) end"
	if enableDebug == true then reaper.ShowConsoleMsg("\n"..tostring(line1).."\n") end
	file:write(line1)
	file:close()

	file2 = io.open(directory..fileNameTabNext,"w")
	line2 = t.."\nif tabToTransient == true and reaper.CountSelectedMediaItems(0) > 0 then reaper.Main_OnCommand(40375, 1)\nelse reaper.Main_OnCommand(40319,1) end"
	if enableDebug == true then reaper.ShowConsoleMsg("\n"..tostring(line2).."\n") end
	file2:write(line2)
	file2:close()
	if enableDebug == true then reaper.ShowConsoleMsg("\nDone.\n") end
end

local function GetDirectory()
	local info = debug.getinfo(1,'S')
	return info.source:match[[^@?(.*[\\/])[^\\/]-$]]
end

local function GetOS()
	local userOS = reaper.GetOS()
	if userOS == "OSX64" or userOS == "OSX32" then
		return "/"
	elseif userOS == "Win32" or userOS == "Win64" then
		return "\\"
	else
		return "/"
	end
end

function mysplit (inputstr, sep) --from strackoverflow user973713
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

--Process

newDir = GetDirectory()

s = tostring(GetOS())
if enableDebug == true then reaper.ShowConsoleMsg("\nScript Directory: "..newDir) end

ReadFile(newDir, fileNameTabNext)
WriteFiles(newDir)
